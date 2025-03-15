from flask import Flask, request, jsonify
from pymongo import MongoClient
from werkzeug.security import generate_password_hash
from datetime import datetime

app = Flask(__name__)

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")
db = client["finace_app"]
users_collection = db["users"]

# Helper function to format MongoDB documents
def format_user(user):
    user["_id"] = str(user["_id"])  # Convert ObjectId to string
    return user

# Signup Endpoint
@app.route('/register', methods=['POST'])
def register():
    try:
        # Get JSON data from the request
        data = request.json

        # Validate required fields
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            return jsonify({"error": "Email and password are required"}), 400

        # Check if the email already exists
        existing_user = users_collection.find_one({"email": email})
        if existing_user:
            return jsonify({"error": "Email already registered"}), 409

        # Hash the password for security
        hashed_password = generate_password_hash(password)

        # Insert the new user into MongoDB
        new_user = {
            "email": email,
            "password": hashed_password,
            "createdAt": datetime.utcnow().isoformat() + "Z"  # Add creation timestamp
        }
        result = users_collection.insert_one(new_user)

        # Return success response
        return jsonify({
            "message": "User registered successfully",
            "user_id": str(result.inserted_id)
        }), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)