from flask import Flask, request, jsonify
from pymongo import MongoClient
from werkzeug.security import generate_password_hash, check_password_hash
from bson.objectid import ObjectId
from bson.errors import InvalidId
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
goals_collection = db["goals"]  # New collection for goals

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
        if not user or not check_password_hash(user["password"], password):
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

    except InvalidId:
        return jsonify({"message": f"'{user_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/users', methods=['GET'])
def get_all_users():
    try:
        users = list(users_collection.find({}))
        return jsonify([format_document(user) for user in users]), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== TRANSACTIONS ====================
@app.route('/transactions', methods=['GET'])
def get_transactions():
    try:
        user_id = request.args.get('user_id')
        query = {"userId": user_id} if user_id else {}
        transactions = list(transactions_collection.find(query))
        return jsonify([format_document(t) for t in transactions]), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/transactions', methods=['POST'])
def add_transaction():
    try:
        data = request.json
        required_fields = ["date", "category", "amount", "userId"]
        if not all(field in data for field in required_fields):
            return jsonify({"message": "Date, category, amount, and userId are required"}), 400

        new_transaction = {
            "date": data["date"],
            "userId": data["userId"],
            "category": data["category"],
            "amount": data["amount"],
            "currency": data.get("currency", "LKR"),
            "note": data.get("note", ""),
            "type": data.get("type", "Expense"),
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

    except InvalidId:
        return jsonify({"message": f"'{transaction_id}' is not a valid ObjectId"}), 400
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

    except InvalidId:
        return jsonify({"message": f"'{transaction_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/transactions/<transaction_id>', methods=['DELETE'])
def delete_transaction(transaction_id):
    try:
        result = transactions_collection.delete_one({"_id": ObjectId(transaction_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Transaction not found"}), 404

        return jsonify({"message": "Transaction deleted successfully"}), 200

    except InvalidId:
        return jsonify({"message": f"'{transaction_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== BUDGETS ====================
@app.route('/budgets', methods=['GET'])
def get_budgets():
    try:
        user_id = request.args.get('user_id')
        query = {"userId": user_id} if user_id else {}
        budgets = list(budgets_collection.find(query))
        return jsonify([format_document(b) for b in budgets]), 200
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/budgets', methods=['POST'])
def add_budget():
    try:
        data = request.json
        required_fields = ["category", "limit", "userId"]
        if not all(field in data for field in required_fields):
            return jsonify({"message": "Category, limit, and userId are required"}), 400

        new_budget = {
            "userId": data["userId"],
            "category": data["category"],
            "limit": data["limit"],
            "currency": data.get("currency", "LKR"),
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

    except InvalidId:
        return jsonify({"message": f"'{budget_id}' is not a valid ObjectId"}), 400
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

    except InvalidId:
        return jsonify({"message": f"'{budget_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/budgets/<budget_id>', methods=['DELETE'])
def delete_budget(budget_id):
    try:
        result = budgets_collection.delete_one({"_id": ObjectId(budget_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Budget not found"}), 404

        return jsonify({"message": "Budget deleted successfully"}), 200

    except InvalidId:
        return jsonify({"message": f"'{budget_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== PREDICTIONS ====================
@app.route('/predictions', methods=['GET'])
def get_predictions():
    try:
        user_id = request.args.get('user_id')
        query = {"userId": user_id} if user_id else {}
        predictions = list(predictions_collection.find(query))
        return jsonify([format_document(p) for p in predictions]), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/predictions', methods=['POST'])
def add_prediction():
    try:
        data = request.json
        required_fields = ["category", "predicted_amount", "userId"]
        if not all(field in data for field in required_fields):
            return jsonify({"message": "Category, predicted_amount, and userId are required"}), 400

        new_prediction = {
            "userId": data["userId"],
            "category": data["category"],
            "predicted_amount": data["predicted_amount"],
            "currency": data.get("currency", "LKR"),
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

    except InvalidId:
        return jsonify({"message": f"'{prediction_id}' is not a valid ObjectId"}), 400
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

    except InvalidId:
        return jsonify({"message": f"'{prediction_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/predictions/<prediction_id>', methods=['DELETE'])
def delete_prediction(prediction_id):
    try:
        result = predictions_collection.delete_one({"_id": ObjectId(prediction_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Prediction not found"}), 404

        return jsonify({"message": "Prediction deleted successfully"}), 200

    except InvalidId:
        return jsonify({"message": f"'{prediction_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== GOALS ====================
@app.route('/goals', methods=['GET'])
def get_goals():
    try:
        user_id = request.args.get('user_id')
        if not user_id:
            return jsonify({"message": "user_id is required"}), 400
        
        goals = list(goals_collection.find({"userId": user_id}))
        return jsonify([format_document(g) for g in goals]), 200

    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/goals', methods=['POST'])
def add_goal():
    try:
        data = request.json
        required_fields = ["userId", "title", "targetAmount", "currentAmount", "deadline"]
        if not all(field in data for field in required_fields):
            return jsonify({"message": "userId, title, targetAmount, currentAmount, and deadline are required"}), 400

        new_goal = {
            "userId": data["userId"],
            "title": data["title"],
            "targetAmount": float(data["targetAmount"]),
            "currentAmount": float(data["currentAmount"]),
            "deadline": data["deadline"],
            "description": data.get("description", ""),
            "currency": data.get("currency", "LKR"),
            "createdAt": datetime.utcnow().isoformat() + "Z",
            "updatedAt": datetime.utcnow().isoformat() + "Z"
        }
        result = goals_collection.insert_one(new_goal)

        return jsonify({
            "message": "Goal added successfully",
            "goal_id": str(result.inserted_id)
        }), 201

    except ValueError as e:
        return jsonify({"message": f"Invalid numeric value: {str(e)}"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/goals/<goal_id>', methods=['GET'])
def get_goal(goal_id):
    try:
        goal = goals_collection.find_one({"_id": ObjectId(goal_id)})
        if not goal:
            return jsonify({"message": "Goal not found"}), 404

        return jsonify(format_document(goal)), 200

    except InvalidId:
        return jsonify({"message": f"'{goal_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/goals/<goal_id>', methods=['PUT'])
def update_goal(goal_id):
    try:
        data = request.json
        updated_data = {k: v for k, v in data.items() if v is not None}
        if "targetAmount" in updated_data:
            updated_data["targetAmount"] = float(updated_data["targetAmount"])
        if "currentAmount" in updated_data:
            updated_data["currentAmount"] = float(updated_data["currentAmount"])
        updated_data["updatedAt"] = datetime.utcnow().isoformat() + "Z"

        result = goals_collection.update_one(
            {"_id": ObjectId(goal_id)},
            {"$set": updated_data}
        )

        if result.matched_count == 0:
            return jsonify({"message": "Goal not found"}), 404

        return jsonify({"message": "Goal updated successfully"}), 200

    except InvalidId:
        return jsonify({"message": f"'{goal_id}' is not a valid ObjectId"}), 400
    except ValueError as e:
        return jsonify({"message": f"Invalid numeric value: {str(e)}"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

@app.route('/goals/<goal_id>', methods=['DELETE'])
def delete_goal(goal_id):
    try:
        result = goals_collection.delete_one({"_id": ObjectId(goal_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Goal not found"}), 404

        return jsonify({"message": "Goal deleted successfully"}), 200

    except InvalidId:
        return jsonify({"message": f"'{goal_id}' is not a valid ObjectId"}), 400
    except Exception as e:
        return jsonify({"message": str(e)}), 500

# ==================== RUN THE APP ====================
if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0")