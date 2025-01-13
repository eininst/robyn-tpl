from robyn import Robyn
import signal
import asyncio

# 初始化 Robyn 应用
app = Robyn(__file__)

# 定义清理函数
async def cleanup():
    print("Performing cleanup tasks...")
    # 在这里关闭数据库连接、释放资源等
    await asyncio.sleep(1)  # 模拟异步清理
    print("Cleanup completed!")

# 注册关闭处理器
@app.shutdown_handler
async def shutdown_handler():
    await cleanup()

# 定义一个简单路由
@app.get("/")
async def home():
    return "Hello, Robyn!"

# 捕获终止信号并优雅关闭
def signal_handler(signal_received, frame):
    print(f"Signal {signal_received} received, shutting down gracefully...")


# 绑定信号处理
signal.signal(signal.SIGINT, signal_handler)  # Ctrl+C
signal.signal(signal.SIGTERM, signal_handler) # Termination signal

# 启动应用
if __name__ == "__main__":
    app.start()
