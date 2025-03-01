from flask import Flask, request, jsonify
from flask_cors import CORS
from pymongo import MongoClient
import bcrypt
from flask_jwt_extended import create_access_token, jwt_required, JWTManager
from bson import ObjectId

app = Flask(__name__)
CORS(app)

# ✅ MongoDB Connection
client = MongoClient("mongodb://localhost:27017/")
db = client["finance_app"]  # Your database name
users_collection = db["users"]
expenses_collection = db["expenses"]

# ✅ JWT Configuration
app.config["JWT_SECRET_KEY"] = "your_secret_key"  # Change this to a secure key
jwt = JWTManager(app)

# ✅ Home Route to Prevent 404 Error
@app.route('/')
def home():
    return jsonify({"message": "Welcome to the Spendio API!"}), 200

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
        access_token = create_access_token(identity=email)
        return jsonify({"token": access_token}), 200

    return jsonify({"message": "Invalid credentials"}), 401

# ✅ Add Expense (Protected Route)
@app.route('/add_expense', methods=['POST'])
@jwt_required()
def add_expense():
    data = request.json
    email = data.get("email")  # Use JWT identity in production
    category = data.get("category")
    amount = data.get("amount")
    date = data.get("date")

    expense = expenses_collection.insert_one({
        "email": email,
        "category": category,
        "amount": amount,
        "date": date
    })
    
    return jsonify({"message": "Expense added successfully", "expense_id": str(expense.inserted_id)}), 201

# ✅ Get All Expenses (Convert `_id` to String)
@app.route('/expenses/<email>', methods=['GET'])
@jwt_required()
def get_expenses(email):
    expenses = list(expenses_collection.find({"email": email}))
    for expense in expenses:
        expense["_id"] = str(expense["_id"])  # Convert ObjectId to string
    return jsonify(expenses), 200

# ✅ Delete Expense (Fix `_id` Handling)
@app.route('/delete_expense/<expense_id>', methods=['DELETE'])
@jwt_required()
def delete_expense(expense_id):
    expenses_collection.delete_one({"_id": ObjectId(expense_id)})
    return jsonify({"message": "Expense deleted successfully"}), 200

# ✅ Update Expense (Fix `_id` Handling)
@app.route('/update_expense/<expense_id>', methods=['PUT'])
@jwt_required()
def update_expense(expense_id):
    data = request.json
    expenses_collection.update_one(
        {"_id": ObjectId(expense_id)},
        {"$set": {
            "category": data.get("category"),
            "amount": data.get("amount"),
            "date": data.get("date")
        }}
    )
    return jsonify({"message": "Expense updated successfully"}), 200

if __name__ == '__main__':
    app.run(debug=True)
