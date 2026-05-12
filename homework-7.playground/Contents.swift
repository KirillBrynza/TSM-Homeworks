import UIKit
import Foundation

// Классы геометрических фигур
class Shape {
    var color: String
    
    init(color: String) {
        self.color = color
    }
    
    func calculateArea() -> Double {
        return 0.0
    }
}
class Circle: Shape {
    var radius: Double
    
    init(color: String, radius: Double) {
        self.radius = radius
        super.init(color: color)
    }
    override func calculateArea() -> Double {
        return Double.pi * radius * radius
    }
}

class Rectangle: Shape {
    var width: Double
    var height: Double
    
    init(color: String, width: Double, height: Double) {
        self.width = width
        self.height = height
        super.init(color: color)
    }
    override func calculateArea() -> Double {
        return width * height
    }
}
class Triangle: Shape {
    var base: Double
    var height: Double

    init(color: String, base: Double, height: Double) {
        self.base = base
        self.height = height
        super.init(color: color)
    }

    override func calculateArea() -> Double {
        return 0.5 * base * height
    }
}

let shapes: [Shape] = [
    Circle(color: "Красный", radius: 5),
    Rectangle(color: "Синий", width: 4, height: 6),
    Triangle(color: "Зеленый", base: 3, height: 8)
]

// Вывод площади фигур
for shape in shapes {
    print("Площадь фигуры: \(shape.calculateArea())")
}

print ("______________________________")

// Стркутуры для контактов

struct Contact {
    let firstName: String
    let lastName: String
    let phoneNumber: String
    let email: String?
}
func searchContacts(contacts: [Contact], searchText: String) -> [Contact] {

    return contacts.filter {
        $0.firstName.lowercased().contains(searchText.lowercased()) ||
        $0.lastName.lowercased().contains(searchText.lowercased())
    }
}

let contacts = [
    Contact(firstName: "Иван", lastName: "Иванов", phoneNumber: "+37544221123", email: "ivan@mail.com"),
    Contact(firstName: "Петр", lastName: "Петров", phoneNumber: "+375296172343", email: nil),
    Contact(firstName: "Анна", lastName: "Сидорова", phoneNumber: "+375334422111", email: "anna@mail.com")
]

let result = searchContacts(contacts: contacts, searchText: "анн")

for contact in result {
    print("\(contact.firstName) \(contact.lastName) \(contact.phoneNumber) \(String(describing: contact.email))")
}
