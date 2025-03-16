from flask import Flask, request, jsonify
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
from bson.objectid import ObjectId
from datetime import datetime

app = Flask(__name__)

# Connect to MongoDB
client = MongoClient("mongodb://localhost:27017/")  # Replace with your connection string if needed
db = client["finace_app"]

# Collections
users_collection = db["users"]
transactions_collection = db["transactions"]
budgets_collection = db["budgets"]
predictions_collection = db["predictions"]

# Helper function to format MongoDB documents
def format_document(document):
    document["_id"] = str(document["_id"])  # Convert ObjectId to string
    return document

# ==================== USERS ====================
@app.route('/register', methods=['POST'])
def register():
    try:
        data = request.json
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            return jsonify({"message": "Email and password are required"}), 400

        existing_user = users_collection.find_one({"email": email})
        if existing_user:
            return jsonify({"message": "Email already registered"}), 409

        hashed_password = generate_password_hash(password)
        new_user = {
            "email": email,
            "password": hashed_password,
            "createdAt": datetime.utcnow().isoformat() + "Z"
        }
        result = users_collection.insert_one(new_user)

        return jsonify({
            "message": "User registered successfully",
            "user_id": str(result.inserted_id)
        }), 201

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/login', methods=['POST'])
def login():
    try:
        data = request.json
        email = data.get("email")
        password = data.get("password")

        if not email or not password:
            return jsonify({"message": "Email and password are required"}), 400

        user = users_collection.find_one({"email": email})
        if not user:
            return jsonify({"message": "Invalid email or password"}), 401

        if not check_password_hash(user["password"], password):
            return jsonify({"message": "Invalid email or password"}), 401

        return jsonify({
            "message": "Login successful",
            "user_id": str(user["_id"])
        }), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id):
    try:
        user = users_collection.find_one({"_id": ObjectId(user_id)})
        if not user:
            return jsonify({"message": "User not found"}), 404

        return jsonify(format_document(user)), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== TRANSACTIONS ====================
@app.route('/transactions', methods=['GET'])
def get_transactions():
    try:
        transactions = list(transactions_collection.find({}))
        return jsonify([format_document(t) for t in transactions]), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/transactions', methods=['POST'])
def add_transaction():
    try:
        data = request.json
        date = data.get("date")
        category = data.get("category")
        amount = data.get("amount")
        currency = data.get("currency", "LKR")

        if not date or not category or not amount:
            return jsonify({"message": "Date, category, and amount are required"}), 400

        new_transaction = {
            "date": date,
            "category": category,
            "amount": amount,
            "currency": currency,
            "createdAt": datetime.utcnow().isoformat() + "Z"
        }
        result = transactions_collection.insert_one(new_transaction)

        return jsonify({
            "message": "Transaction added successfully",
            "transaction_id": str(result.inserted_id)
        }), 201

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/transactions/<transaction_id>', methods=['GET'])
def get_transaction(transaction_id):
    try:
        transaction = transactions_collection.find_one({"_id": ObjectId(transaction_id)})
        if not transaction:
            return jsonify({"message": "Transaction not found"}), 404

        return jsonify(format_document(transaction)), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/transactions/<transaction_id>', methods=['PUT'])
def update_transaction(transaction_id):
    try:
        data = request.json
        updated_data = {k: v for k, v in data.items() if v is not None}

        result = transactions_collection.update_one(
            {"_id": ObjectId(transaction_id)},
            {"$set": updated_data}
        )

        if result.matched_count == 0:
            return jsonify({"message": "Transaction not found"}), 404

        return jsonify({"message": "Transaction updated successfully"}), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/transactions/<transaction_id>', methods=['DELETE'])
def delete_transaction(transaction_id):
    try:
        result = transactions_collection.delete_one({"_id": ObjectId(transaction_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Transaction not found"}), 404

        return jsonify({"message": "Transaction deleted successfully"}), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== BUDGETS ====================
@app.route('/budgets', methods=['GET'])
def get_budgets():
    try:
        budgets = list(budgets_collection.find({}))
        return jsonify([format_document(b) for b in budgets]), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/budgets', methods=['POST'])
def add_budget():
    try:
        data = request.json
        category = data.get("category")
        limit = data.get("limit")
        currency = data.get("currency", "INR")

        if not category or not limit:
            return jsonify({"message": "Category and limit are required"}), 400

        new_budget = {
            "category": category,
            "limit": limit,
            "currency": currency,
            "createdAt": datetime.utcnow().isoformat() + "Z"
        }
        result = budgets_collection.insert_one(new_budget)

        return jsonify({
            "message": "Budget added successfully",
            "budget_id": str(result.inserted_id)
        }), 201

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/budgets/<budget_id>', methods=['GET'])
def get_budget(budget_id):
    try:
        budget = budgets_collection.find_one({"_id": ObjectId(budget_id)})
        if not budget:
            return jsonify({"message": "Budget not found"}), 404

        return jsonify(format_document(budget)), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/budgets/<budget_id>', methods=['PUT'])
def update_budget(budget_id):
    try:
        data = request.json
        updated_data = {k: v for k, v in data.items() if v is not None}

        result = budgets_collection.update_one(
            {"_id": ObjectId(budget_id)},
            {"$set": updated_data}
        )

        if result.matched_count == 0:
            return jsonify({"message": "Budget not found"}), 404

        return jsonify({"message": "Budget updated successfully"}), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/budgets/<budget_id>', methods=['DELETE'])
def delete_budget(budget_id):
    try:
        result = budgets_collection.delete_one({"_id": ObjectId(budget_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Budget not found"}), 404

        return jsonify({"message": "Budget deleted successfully"}), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== PREDICTIONS ====================
@app.route('/predictions', methods=['GET'])
def get_predictions():
    try:
        predictions = list(predictions_collection.find({}))
        return jsonify([format_document(p) for p in predictions]), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/predictions', methods=['POST'])
def add_prediction():
    try:
        data = request.json
        category = data.get("category")
        predicted_amount = data.get("predicted_amount")
        currency = data.get("currency", "INR")

        if not category or not predicted_amount:
            return jsonify({"message": "Category and predicted amount are required"}), 400

        new_prediction = {
            "category": category,
            "predicted_amount": predicted_amount,
            "currency": currency,
            "createdAt": datetime.utcnow().isoformat() + "Z"
        }
        result = predictions_collection.insert_one(new_prediction)

        return jsonify({
            "message": "Prediction added successfully",
            "prediction_id": str(result.inserted_id)
        }), 201

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/predictions/<prediction_id>', methods=['GET'])
def get_prediction(prediction_id):
    try:
        prediction = predictions_collection.find_one({"_id": ObjectId(prediction_id)})
        if not prediction:
            return jsonify({"message": "Prediction not found"}), 404

        return jsonify(format_document(prediction)), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/predictions/<prediction_id>', methods=['PUT'])
def update_prediction(prediction_id):
    try:
        data = request.json
        updated_data = {k: v for k, v in data.items() if v is not None}

        result = predictions_collection.update_one(
            {"_id": ObjectId(prediction_id)},
            {"$set": updated_data}
        )

        if result.matched_count == 0:
            return jsonify({"message": "Prediction not found"}), 404

        return jsonify({"message": "Prediction updated successfully"}), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/predictions/<prediction_id>', methods=['DELETE'])
def delete_prediction(prediction_id):
    try:
        result = predictions_collection.delete_one({"_id": ObjectId(prediction_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Prediction not found"}), 404

        return jsonify({"message": "Prediction deleted successfully"}), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== RUN THE APP ====================
if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")  # Use host="0.0.0.0" to make the server accessible on your network