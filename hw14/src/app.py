from flask import Flask, jsonify, request
import csv
import os

app = Flask(__name__)

FILE_PATH = 'students.csv'

def read_students():
    students = []
    if os.path.exists(FILE_PATH):
        with open(FILE_PATH, mode='r') as file:
            reader = csv.DictReader(file)
            for row in reader:
                students.append(row)
    return students

def write_students(students):
    with open(FILE_PATH, mode='w', newline='') as file:
        fieldnames = ['id', 'first_name', 'last_name', 'age']
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        for student in students:
            writer.writerow(student)

@app.route('/students', methods=['GET'])
def get_students():
    students = read_students()
    return jsonify(students)

@app.route('/students/<int:id>', methods=['GET'])
def get_student(id):
    students = read_students()
    student = next((s for s in students if int(s['id']) == id), None)
    if student:
        return jsonify(student)
    return jsonify({'error': 'Student not found'}), 404

@app.route('/students/lastname/<last_name>', methods=['GET'])
def get_students_by_lastname(last_name):
    students = read_students()
    filtered_students = [s for s in students if s['last_name'].lower() == last_name.lower()]
    if filtered_students:
        return jsonify(filtered_students)
    return jsonify({'error': 'No students found with that last name'}), 404

@app.route('/students', methods=['POST'])
def add_student():
    data = request.get_json()
    if not all(key in data for key in ['first_name', 'last_name', 'age']):
        return jsonify({'error': 'Missing required fields'}), 400
    
    students = read_students()
    new_id = max([int(s['id']) for s in students], default=0) + 1
    new_student = {
        'id': new_id,
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'age': data['age']
    }
    students.append(new_student)
    write_students(students)
    return jsonify(new_student), 201

@app.route('/students/<int:id>', methods=['PUT'])
def update_student(id):
    data = request.get_json()
    if not all(key in data for key in ['first_name', 'last_name', 'age']):
        return jsonify({'error': 'Missing required fields'}), 400
    
    students = read_students()
    student = next((s for s in students if int(s['id']) == id), None)
    if student:
        student['first_name'] = data['first_name']
        student['last_name'] = data['last_name']
        student['age'] = data['age']
        write_students(students)
        return jsonify(student)
    return jsonify({'error': 'Student not found'}), 404

@app.route('/students/<int:id>/age', methods=['PATCH'])
def update_student_age(id):
    data = request.get_json()
    if 'age' not in data:
        return jsonify({'error': 'Missing age field'}), 400
    
    students = read_students()
    student = next((s for s in students if int(s['id']) == id), None)
    if student:
        student['age'] = data['age']
        write_students(students)
        return jsonify(student)
    return jsonify({'error': 'Student not found'}), 404

@app.route('/students/<int:id>', methods=['DELETE'])
def delete_student(id):
    students = read_students()
    student = next((s for s in students if int(s['id']) == id), None)
    if student:
        students.remove(student)
        write_students(students)
        return jsonify({'message': 'Student deleted successfully'})
    return jsonify({'error': 'Student not found'}), 404

if __name__ == '__main__':
    app.run(debug=True)

