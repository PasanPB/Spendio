import os
import json
from pymongo import MongoClient
from bson.objectid import ObjectId  # Import ObjectId

# Step 1: Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")  # Replace with your connection string if needed
db = client["finace_app"]  # Replace with your database name

# Step 2: Define the directory containing JSON files
data_directory = "data"  # Replace with the path to your JSON files

# Step 3: Iterate through all JSON files in the directory
for filename in os.listdir(data_directory):
    if filename.endswith(".json"):  # Process only JSON files
        file_path = os.path.join(data_directory, filename)
        collection_name = filename.split(".")[0]  # Use the file name as the collection name
        collection = db[collection_name]

        # Step 4: Load the JSON file
        with open(file_path, 'r') as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError as e:
                print(f"Error decoding JSON from file {filename}: {e}")
                continue

        # Step 5: Ensure the data is not empty
        if not data:
            print(f"The file {filename} is empty or improperly formatted. Skipping...")
            continue

        # Step 6: Insert the data into the collection
        try:
            if isinstance(data, list):  # Check if data is a list of documents
                for document in data:
                    # Convert _id to ObjectId if it exists
                    if "_id" in document:
                        try:
                            document["_id"] = ObjectId(document["_id"])
                        except Exception as e:
                            print(f"Invalid _id format in document: {document}. Error: {e}")
                            continue  # Skip invalid _id entries

                    # Convert userId to ObjectId if it exists
                    if "userId" in document:
                        try:
                            document["userId"] = ObjectId(document["userId"])
                        except Exception as e:
                            print(f"Invalid userId format in document: {document}. Error: {e}")
                            continue  # Skip invalid userId entries

                result = collection.insert_many(data)
                print(f"Inserted {len(result.inserted_ids)} records into the '{collection_name}' collection.")
            elif isinstance(data, dict):  # Check if data is a single document
                # Convert _id to ObjectId if it exists
                if "_id" in data:
                    try:
                        data["_id"] = ObjectId(data["_id"])
                    except Exception as e:
                        print(f"Invalid _id format in document: {data}. Error: {e}")
                        continue  # Skip invalid _id entries

                # Convert userId to ObjectId if it exists
                if "userId" in data:
                    try:
                        data["userId"] = ObjectId(data["userId"])
                    except Exception as e:
                        print(f"Invalid userId format in document: {data}. Error: {e}")
                        continue  # Skip invalid userId entries

                result = collection.insert_one(data)
                print(f"Inserted 1 record into the '{collection_name}' collection.")
            else:
                print(f"Invalid data format in file {filename}. Skipping...")
        except Exception as e:
            print(f"Error inserting data into collection '{collection_name}': {e}")