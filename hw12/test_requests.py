
import requests
import json

BASE_URL = "http://127.0.0.1:5000/students"

with open("results.txt", "w") as results_file:
    
    response = requests.get(BASE_URL)
    results_file.write("Step 1: Retrieve all existing students (GET)\n")
    print("Step 1: Retrieve all existing students (GET)\n", response.json())
    results_file.write(json.dumps(response.json(), indent=4) + "\n\n")
    
    student1 = {"first_name": "Alice", "last_name": "Johnson", "age": 20}
    student2 = {"first_name": "Bob", "last_name": "Smith", "age": 22}
    student3 = {"first_name": "Charlie", "last_name": "Brown", "age": 23}
    
    response1 = requests.post(BASE_URL, json=student1)
    response2 = requests.post(BASE_URL, json=student2)
    response3 = requests.post(BASE_URL, json=student3)
    
    results_file.write("Step 2: Create three students (POST)\n")
    print("Step 2: Create three students (POST)\n", response1.json(), response2.json(), response3.json())
    results_file.write(json.dumps(response1.json(), indent=4) + "\n")
    results_file.write(json.dumps(response2.json(), indent=4) + "\n")
    results_file.write(json.dumps(response3.json(), indent=4) + "\n\n")
    
    response = requests.get(BASE_URL)
    results_file.write("Step 3: Retrieve information about all existing students (GET)\n")
    print("Step 3: Retrieve information about all existing students (GET)\n", response.json())
    results_file.write(json.dumps(response.json(), indent=4) + "\n\n")
    
    student_id_to_patch = 2
    updated_data = {"age": 25}
    response = requests

