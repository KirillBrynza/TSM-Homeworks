import UIKit

func helloWorld() {
    print("Hello, World!")
}

helloWorld()
print("____________________________")
func printHi(name: String) {
    print("Hello, \(name)!")
}

printHi(name: "Иван")
print("____________________________")
func getHello (name: String) -> String {
    return "Hello, \(name)!"
}

print(getHello(name: "Виктор"))
print("____________________________")
func sumLength(_ str1: String, _ str2: String) -> Int {
    return str1.count + str2.count
}

print(sumLength("Hello", "World"))
print("____________________________")
func squareNumber(_ number: Int) {
    print(number * number)
}

squareNumber(5)
print("____________________________")
func circleArea(radius: Double) -> Double {
    return Double.pi * radius * radius
}

print(circleArea(radius: 3))
print("____________________________")
func getTimeOfDay(hour: Int) -> String {
    switch hour {
    case 6..<12:
        return "Утро"
    case 12..<18:
        return "День"
    case 18..<24:
        return "Вечер"
    case 0..<6:
        return "Ночь"
    default:
        return "Неверный час"
    }
}

print(getTimeOfDay(hour: 15)) // (проверка верный час ДЕНЬ)
print(getTimeOfDay(hour: 25)) // (проверка неверный час)
print("____________________________")
func getSeason(month: Int) -> String {
    switch month {
    case 12, 1, 2:
        return "Зима"
    case 3, 4, 5:
        return "Весна"
    case 6, 7, 8:
        return "Лето"
    case 9, 10, 11:
        return "Осень"
    default:
        return "Неверный номер месяца"
    }
}

print(getSeason(month: 7)) // (проверил месяц ЛЕТО)
print(getSeason(month: 13)) // (несуществующий месяц)
print("____________________________")
func parsePhone(_ phone: String) {
    
    let countryCode = phone.prefix(4)
    let operatorStart = phone.index(phone.startIndex, offsetBy: 4)
    let operatorEnd = phone.index(operatorStart, offsetBy: 2)
    let operatorCode = phone[operatorStart..<operatorEnd]
    
    let number = phone.suffix(phone.count - 6)
    
    print("Код страны: \(countryCode)")
    print("Код оператора: \(operatorCode)")
    print("Номер: \(number)")
}

parsePhone("+375295124312")
