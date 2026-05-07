import UIKit
import Foundation

typealias Student = (
    name: String,
    age: Int,
    grades: [String: Double],
    electives: Set<String>
)
// Массив 5 студентов (честно подсмотрел в интернете как его привести в такой вид, чтобы выглядело таким образом)
let students: [Student] = [
    (
        name: "Алексей",
        age: 20,
        grades: ["Математика": 4.0, "Физика": 3.5, "Химия": 3.8],
        electives: ["История", "География"]
    ),
    (
        name: "Мария",
        age: 19,
        grades: ["Математика": 3.0, "Физика": 3.2, "Химия": 3.5],
        electives: ["История", "География", "Английский"]
    ),
    (
        name: "Павел",
    age: 20,
    grades: ["Математика": 4.5, "Физика": 3.9, "Химия": 4.2],
    electives: ["История", "География"]
    ),
    (
        name: "Кристина",
        age: 22,
        grades: ["Математика": 4.5, "Физика": 4.9, "Химия": 4.8],
        electives: ["История", "География", "Английский"]
    ),
    (
        name: "Антон",
        age: 18,
        grades: ["Математика": 2.5, "Физика": 2.8, "Химия": 3.0],
        electives: ["История", "География"]
   )
]

// Функия для подсчёта среднего балла студента
func calculateAverageGrade(student: Student) -> Double? {
    guard !student.grades.isEmpty else {
        return nil
    }

    let sum = student.grades.values.reduce(0, +)
    return sum / Double(student.grades.count)
}

// Поиск по возрасту студентов
func findStudentsByAge(students: [Student], age: Int) -> [Student] {
    return students.filter { $0.age == age }
}

// Топ студентов по среднему баллу
func getTopStudents(
    students: [Student],
    top: Int
) -> [(name: String, averageGrade: Double)] {

    return students
        .compactMap { student -> (name: String, averageGrade: Double)? in
            guard let average = calculateAverageGrade(student: student) else {
                return nil
            }

            return (name: student.name, averageGrade: average)
        }
        .sorted { $0.averageGrade > $1.averageGrade }
        .prefix(top)
        .map { $0 }
}

// Все уникальные факультативы
func getUniqueElectives(students: [Student]) -> Set<String> {
    return students.reduce(into: Set<String>()) { result, student in
        result.formUnion(student.electives)
    }
}

// Выводим инфу о студентах (возраст, имя и тд)

print("Информация о студентах:")

for student in students {
    let averageText: String

    if let average = calculateAverageGrade(student: student) {
        averageText = String(format: "%.2f", average)
    } else {
        averageText = "Нет оценок"
    }
// (подсмотрел в интернете как красиво выделить запятыми факультативы, единственное что я бы ещё добавил пробелы между каждыми студентами в консоли для удобства)
    print("""
    Имя: \(student.name)
    Возраст: \(student.age)
    Средний балл: \(averageText)
    Факультативы: \(student.electives.joined(separator: ", ")) 
    """)
}
print ("_________________________________________")
// Студенты возраста 20 лет
print("Студенты возраста 20 лет:")

let studentsAge20 = findStudentsByAge(students: students, age: 20)

for student in studentsAge20 {
    print(student.name)
}

print ("_________________________________________")
// Топ-3 студентов
print("Топ-3 студента:")

let topStudents = getTopStudents(students: students, top: 3)

for (index, student) in topStudents.enumerated() {
    print("\(index + 1). \(student.name) - \(String(format: "%.2f", student.averageGrade))")
}
print ("_________________________________________")
// Уникальные факультативы
print("Все уникальные факультативы:")

let uniqueSubjects = getUniqueElectives(students: students)

for subject in uniqueSubjects.sorted() {
    print(subject)
}
