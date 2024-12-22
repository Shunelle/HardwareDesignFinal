import serial
import pygame
import os

# 初始化 Pygame 混音器
pygame.mixer.init()

# 串口設定
SERIAL_PORT = "/dev/cu.usbmodem11201"
BAUD_RATE = 9600

# 音檔對應表
SOUND_FILES = {
    8: "init.wav",
    4: "game.wav",
    2: "win.wav",
    1: "lose.wav",
}

def play_sound(file_path):
    """播放音樂，若有音樂正在播放則切換"""
    if pygame.mixer.music.get_busy():
        pygame.mixer.music.stop()  # 停止當前播放的音樂
    if os.path.exists(file_path):
        pygame.mixer.music.load(file_path)
        pygame.mixer.music.play()
        print(f"播放音樂: {file_path}")
    else:
        print(f"音檔不存在: {file_path}")

def main():
    last_signal = None  # 儲存上一次的信號
    
    try:
        # 開啟串口
        with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
            print("等待訊號...")
            while True:
                if ser.in_waiting > 0:  # 檢查是否有訊號
                    signal = ser.readline().decode('utf-8').strip()
                    if signal.isdigit():
                        signal_value = int(signal)
                        
                        # 只在信號發生變化時執行操作
                        if signal_value != last_signal:
                            print(f"接收到新的訊號: {signal_value}")
                            last_signal = signal_value  # 更新信號
                            
                            if signal_value in SOUND_FILES:
                                play_sound(SOUND_FILES[signal_value])
                            else:
                                print("未知的訊號")
                        else:
                            print(f"信號未改變，維持當前播放狀態 ({signal_value})")
    except serial.SerialException as e:
        print(f"串口錯誤: {e}")
    except KeyboardInterrupt:
        print("程式結束")
    finally:
        pygame.mixer.quit()

if __name__ == "__main__":
    main()
