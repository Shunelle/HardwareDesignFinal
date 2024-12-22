from playsound import playsound

# 測試音樂檔案
try:
    print("播放音樂測試開始...")
    playsound("init.L.wav")  # 將 "test.wav" 替換為您的音檔名稱
    print("播放結束！")
except Exception as e:
    print(f"播放失敗: {e}")