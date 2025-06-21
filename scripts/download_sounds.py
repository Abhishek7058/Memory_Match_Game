#!/usr/bin/env python3
"""
Script to help download free sound effects for the Memory Match Game.
This script provides URLs and instructions for getting sound files.
"""

import os
import urllib.request
from pathlib import Path

def create_sounds_directory():
    """Create the sounds directory if it doesn't exist."""
    sounds_dir = Path("assets/sounds")
    sounds_dir.mkdir(parents=True, exist_ok=True)
    return sounds_dir

def download_file(url, filename):
    """Download a file from URL."""
    try:
        urllib.request.urlretrieve(url, filename)
        print(f"✅ Downloaded: {filename}")
        return True
    except Exception as e:
        print(f"❌ Failed to download {filename}: {e}")
        return False

def main():
    print("🎵 Memory Match Game - Sound Setup Helper")
    print("=" * 50)
    
    sounds_dir = create_sounds_directory()
    
    print("\n📁 Created sounds directory at:", sounds_dir.absolute())
    
    print("\n🔊 Recommended Free Sound Sources:")
    print("1. Freesound.org - Free sounds with Creative Commons licenses")
    print("2. Zapsplat.com - Free with account registration")
    print("3. Pixabay.com - Free sound effects")
    print("4. Mixkit.co - Free sound effects")
    
    print("\n🎯 Sound Files Needed:")
    sound_files = [
        ("flip.mp3", "Card flip sound - short click or whoosh"),
        ("match.mp3", "Match found sound - positive chime or ding"),
        ("victory.mp3", "Game complete sound - celebration or fanfare")
    ]
    
    for filename, description in sound_files:
        print(f"  • {filename} - {description}")
    
    print("\n📋 Manual Download Instructions:")
    print("1. Visit one of the recommended sound sources above")
    print("2. Search for sounds matching the descriptions")
    print("3. Download and rename files to match the required names")
    print("4. Place files in the assets/sounds/ directory")
    print("5. Run 'flutter pub get' to refresh assets")
    
    print("\n🔧 Alternative - Create Simple Beep Sounds:")
    print("You can also create simple beep sounds using online tone generators:")
    print("• Online Tone Generator: https://www.szynalski.com/tone-generator/")
    print("• Generate different frequency tones (e.g., 800Hz, 1000Hz, 1200Hz)")
    print("• Export as MP3 files")
    
    print("\n✅ After adding sound files:")
    print("1. Make sure files are named exactly: flip.mp3, match.mp3, victory.mp3")
    print("2. Run: flutter clean && flutter pub get")
    print("3. Test sounds using the Sound Test Panel in the app")

if __name__ == "__main__":
    main()
