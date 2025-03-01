from pymongo import MongoClient

client = MongoClient("mongodb://127.0.0.1:27017/")
db = client["finance_app"]

try:
    db.command("ping")
    print("MongoDB connected successfully!")
except Exception as e:
    print("MongoDB connection failed:", e)
