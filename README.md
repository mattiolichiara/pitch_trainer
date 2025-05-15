# PITCH TRAINER

Pitch Trainer - Mobile Application

## OVERVIEW<br/>
Pitch Trainer is a real-time pitch detection app that helps musicians and audio enthusiasts accurately tune their instruments. It provides detailed feedback on pitch, frequency, MIDI note, and more, with customizable settings for optimal performance. <br>
<img src="MEDIA/gif.gif" width="200">

## HOME PAGE
- **Note & Octave**: Displays the detected musical note (e.g., A4, C#5).

- **Pitch Deviation Bar**: Visual indicator showing how far the pitch is from the target.

- **Frequency**: The detected frequency in Hz (e.g., 440.0 Hz).

- **Accuracy Percentage**: Shows tuning accuracy from 0% to 100%.

- **MIDI Note**: The corresponding MIDI note number.

- **Volume Bar**: Dynamic indicator of input volume.

- **Sound Wave Visualization**: Real-time waveform display (can be toggled).

- **Dynamic Note Color**: Changes based on tuning accuracy (e.g., red for far off, green for in-tune).

- **Microphone Mute**: Ability to disable microphone input.<br><br>

<img src="https://github.com/user-attachments/assets/fcc854ae-5187-4d90-a520-0280d8405825" width="200">
<img src="https://github.com/user-attachments/assets/5088112d-4dff-43c5-ab57-8795e860dda9" width="200">
<img src="https://github.com/user-attachments/assets/060a22ee-1b0c-4710-8bb1-153623336f1e" width="200"><br/>

## INSTRUMENT PRESETS
- **Instrument Presets**: Predefined frequency detection ranges for common instruments (e.g., Guitar, Violin, Bass).
- **Custom Frequency Range**: Adjustable via scroll wheel for non-standard instruments.<br/><br/>

<img src="https://github.com/user-attachments/assets/4347c05f-ccdb-460a-bc10-fc3419fc0967" width="200">
<img src="https://github.com/user-attachments/assets/ed2faf54-a601-4595-b959-cf939679b950" width="200"><br>

## GENERAL SETTINGS

- **Language**: English or Italian.

- **Color Themes**: 7 different UI color schemes.

- **Screen Always On**: Prevents screen dimming/locking during use.

- **Reset on Silence**: Toggle whether detected values reset when no sound is detected.

- **Toggle Sound Wave Visibility**: (On/Off).

- **Waveform Type**: Choose between Raw or Polished waveform rendering.

- **Reset All Settings**: Restores default configurations.<br><br>

<img src="https://github.com/user-attachments/assets/c5b7a286-7a89-4e11-9781-c9b34bff0f5b" width="200">
<img src="https://github.com/user-attachments/assets/b42fa773-5934-478d-9915-e87b99e81f94" width="200"><br>

## TUNING & PRECISION

- **Reference Pitch (A4)**: Adjustable standard (default: 440 Hz).

- **Detection Tolerance**: Fine-tune sensitivity for pitch recognition.

- **Precision Settings**: Control how strictly pitch accuracy is calculated.<br>

## ADVANCED SETTIGS

- **Sample Range**: Modify the audio sample size for detection.

- **Buffer Size**: Adjust processing buffer for performance optimization.<br><br>

<img src="https://github.com/user-attachments/assets/43760bd1-efdd-486a-9001-adc3594a0399" width="200"><br>

## DETAILS
- Audio processing via [flutter_pitch_detection: ^1.3.1](https://pub.dev/packages/flutter_pitch_detection) (integrates TarsosDSP).<br/>
