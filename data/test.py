from pymongo import MongoClient

try:
    # Attempt to connect to MongoDB
    client = MongoClient("mongodb://localhost:27017/")
    print("MongoDB is running.")
    print("Database names:", client.list_database_names())
except Exception as e:
    print("MongoDB is not running or there was an error:", e)