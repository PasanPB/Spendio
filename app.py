from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import bcrypt
from flask_jwt_extended import create_access_token, jwt_required, JWTManager, get_jwt_identity
from bson import ObjectId  # Import ObjectId to handle MongoDB IDs

app = Flask(__name__)
CORS(app, supports_credentials=True)  # Improved CORS handling

# ✅ MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client["finance_db"]  # Change database name as needed
users_collection = db["users"]
expenses_collection = db["expenses"]

# ✅ JWT Configuration
app.config["JWT_SECRET_KEY"] = "your_secret_key"  # Change this to a secure key
jwt = JWTManager(app)

# ✅ Home Route
@app.route('/', methods=['GET'])
def home():
    return jsonify({"message": "Welcome to Spendio API"}), 200

# ✅ User Registration
@app.route('/register', methods=['POST'])
def register():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    if users_collection.find_one({"email": email}):
        return jsonify({"message": "Email already exists"}), 400

    hashed_password = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
    users_collection.insert_one({"email": email, "password": hashed_password.decode('utf-8')})

    return jsonify({"message": "User registered successfully"}), 201

# ✅ User Login
@app.route('/login', methods=['POST'])
def login():
    data = request.json
    email = data.get("email")
    password = data.get("password")

    user = users_collection.find_one({"email": email})
    if user and bcrypt.checkpw(password.encode('utf-8'), user["password"].encode('utf-8')):
        access_token = create_access_token(identity=email)  # Token issued
        return jsonify({"token": access_token}), 200

    return jsonify({"message": "Invalid credentials"}), 401

# ✅ Add Expense (Protected)
@app.route('/add_expense', methods=['POST'])
@jwt_required()
def add_expense():
    data = request.json
    user_email = get_jwt_identity()  # Extract email from JWT
    category = data.get("category")
    amount = data.get("amount")
    date = data.get("date")

    expenses_collection.insert_one({
        "email": user_email,
        "category": category,
        "amount": amount,
        "date": date
    })

    return jsonify({"message": "Expense added successfully"}), 201

# ✅ Get All Expenses (Protected)
@app.route('/expenses', methods=['GET'])
@jwt_required()
def get_expenses():
    user_email = get_jwt_identity()  # Extract email from JWT
    expenses = list(expenses_collection.find({"email": user_email}, {"_id": 1, "category": 1, "amount": 1, "date": 1}))
    
    # Convert ObjectId to string
    for expense in expenses:
        expense["_id"] = str(expense["_id"])
    
    return jsonify(expenses), 200

# ✅ Delete Expense (Protected)
@app.route('/delete_expense/<string:expense_id>', methods=['DELETE'])
@jwt_required()
def delete_expense(expense_id):
    try:
        result = expenses_collection.delete_one({"_id": ObjectId(expense_id)})
        if result.deleted_count == 0:
            return jsonify({"message": "Expense not found"}), 404
        return jsonify({"message": "Expense deleted successfully"}), 200
    except:
        return jsonify({"message": "Invalid Expense ID"}), 400

# ✅ Update Expense (Protected)
@app.route('/update_expense/<string:expense_id>', methods=['PUT'])
@jwt_required()
def update_expense(expense_id):
    data = request.json
    try:
        result = expenses_collection.update_one(
            {"_id": ObjectId(expense_id)},
            {"$set": {
                "category": data.get("category"),
                "amount": data.get("amount"),
                "date": data.get("date")
            }}
        )
        if result.modified_count == 0:
            return jsonify({"message": "Expense not found or no changes made"}), 404
        return jsonify({"message": "Expense updated successfully"}), 200
    except:
        return jsonify({"message": "Invalid Expense ID"}), 400

if __name__ == '__main__':
    app.run(debug=True)
