import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'game_event.dart';
import 'game_state.dart';
import '../models/game_card.dart';
import '../models/game_stats.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../utils/card_generator.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final StorageService _storageService;
  final AudioService _audioService;
  Timer? _timer;

  // Expose services for UI components
  AudioService get audioService => _audioService;
  StorageService get storageService => _storageService;

  GameBloc({
    required StorageService storageService,
    required AudioService audioService,
  })  : _storageService = storageService,
        _audioService = audioService,
        super(GameInitial()) {
    on<StartNewGame>(_onStartNewGame);
    on<FlipCard>(_onFlipCard);
    on<ResetGame>(_onResetGame);
    on<TimerTick>(_onTimerTick);
    on<CheckMatch>(_onCheckMatch);
    on<LoadBestScore>(_onLoadBestScore);

    add(LoadBestScore());
  }

  Future<void> _onStartNewGame(
    StartNewGame event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());

    final cards = CardGenerator.generateCards(event.difficulty);
    final bestScore = await _storageService.getBestScore(event.difficulty);

    emit(GameInProgress(
      cards: cards,
      stats: const GameStats(),
      difficulty: event.difficulty,
      bestScore: bestScore,
    ));

    _startTimer();
  }

  Future<void> _onFlipCard(
    FlipCard event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameInProgress) return;

    final currentState = state as GameInProgress;
    
    if (!currentState.canFlip ||
        currentState.flippedCardIndices.length >= 2 ||
        currentState.cards[event.cardIndex].isFlipped ||
        currentState.cards[event.cardIndex].isMatched) {
      return;
    }

    await _audioService.playFlipSound();

    final updatedCards = List<GameCard>.from(currentState.cards);
    updatedCards[event.cardIndex] = updatedCards[event.cardIndex].copyWith(
      isFlipped: true,
    );

    final newFlippedIndices = [...currentState.flippedCardIndices, event.cardIndex];

    emit(currentState.copyWith(
      cards: updatedCards,
      flippedCardIndices: newFlippedIndices,
      canFlip: newFlippedIndices.length < 2,
    ));

    if (newFlippedIndices.length == 2) {
      // Reduced delay for faster gameplay
      await Future.delayed(const Duration(milliseconds: 200));
      add(CheckMatch());
    }
  }

  Future<void> _onCheckMatch(
    CheckMatch event,
    Emitter<GameState> emit,
  ) async {
    if (state is! GameInProgress) return;

    final currentState = state as GameInProgress;
    
    if (currentState.flippedCardIndices.length != 2) return;

    final firstIndex = currentState.flippedCardIndices[0];
    final secondIndex = currentState.flippedCardIndices[1];
    final firstCard = currentState.cards[firstIndex];
    final secondCard = currentState.cards[secondIndex];

    final updatedCards = List<GameCard>.from(currentState.cards);
    final newMoves = currentState.stats.moves + 1;

    if (firstCard.value == secondCard.value) {
      // Match found
      await _audioService.playMatchSound();
      
      updatedCards[firstIndex] = firstCard.copyWith(isMatched: true);
      updatedCards[secondIndex] = secondCard.copyWith(isMatched: true);
    } else {
      // No match
      updatedCards[firstIndex] = firstCard.copyWith(isFlipped: false);
      updatedCards[secondIndex] = secondCard.copyWith(isFlipped: false);
    }

    final newStats = currentState.stats.copyWith(moves: newMoves);

    // Check if game is completed
    final allMatched = updatedCards.every((card) => card.isMatched);
    
    if (allMatched) {
      _timer?.cancel();

      final completedStats = newStats.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );

      try {
        final currentBestScore = await _storageService.getBestScore(currentState.difficulty);
        final isNewBest = completedStats.score > currentBestScore;

        // Always save game history first
        await _storageService.saveGameHistory(
          currentState.difficulty,
          completedStats,
        );

        // Save best score if it's a new record
        if (isNewBest) {
          await _storageService.saveBestScore(
            currentState.difficulty,
            completedStats.score,
          );
          await _audioService.playVictorySound();
        }

        emit(GameCompleted(
          stats: completedStats,
          difficulty: currentState.difficulty,
          isNewBestScore: isNewBest,
        ));
      } catch (e) {
        // Even if storage fails, still show completion
        if (kDebugMode) {
          print('Error saving victory data: $e');
        }
        emit(GameCompleted(
          stats: completedStats,
          difficulty: currentState.difficulty,
          isNewBestScore: false,
        ));
      }
    } else {
      emit(currentState.copyWith(
        cards: updatedCards,
        stats: newStats,
        flippedCardIndices: [],
        canFlip: true,
      ));
    }
  }

  void _onResetGame(ResetGame event, Emitter<GameState> emit) {
    _timer?.cancel();
    emit(GameInitial());
  }

  void _onTimerTick(TimerTick event, Emitter<GameState> emit) {
    if (state is GameInProgress) {
      final currentState = state as GameInProgress;
      final newStats = currentState.stats.copyWith(
        seconds: currentState.stats.seconds + 1,
      );
      emit(currentState.copyWith(stats: newStats));
    }
  }

  Future<void> _onLoadBestScore(
    LoadBestScore event,
    Emitter<GameState> emit,
  ) async {
    // This is handled in other events when needed
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(TimerTick());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
} 