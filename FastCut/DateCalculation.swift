//
//  DateCalculation.swift
//  FastCut
//
//  Created by ByungHoon Ann on 2022/12/07.
//

import Foundation

// MARK: 요일 리턴 함수
final class DateCalculation {
    static let shared = DateCalculation()
    let format = DateFormatter()
    let calendar = Calendar.current
    private init() { }
    
    // MARK: 년월일 계산
    
    func getWeekFirstDay(atYear: Int, atMonth: Int, atDay: Int) -> Int {
        // var firstWeekDay = ""
        let preYear = atYear - 1
        let preYearDays = (preYear) * 365 + (preYear/4 - preYear/100 + preYear/400)
        var totalDay = 0

        for i in 1..<atMonth {
            totalDay += endDayOfMonth(year: atYear, month: i)
        }

        let weekofDayNumber = (preYearDays + totalDay + atDay) % 7
        // firstWeekDay = days[(preYearDays + totalDay + atDay) % 7]
        // let sampleText = "\(atYear)년 \(atMonth)월 \(atDay)일은 " + firstWeekDay + "요일 입니다."
        return weekofDayNumber
    }

    // MARK: 해당월 일수 계산함수
    
    func endDayOfMonth(year: Int, month: Int) -> Int {
        var endDay: Int = 0
        let inputMonth: Int = month

        let monA: Set = [1, 3, 5, 7, 8, 10, 12]
        let monB: Set = [4, 6, 9, 11]

        if monA.contains(inputMonth) {
            endDay = 31
        } else if monB.contains(inputMonth) {
            endDay = 30
        }

        if inputMonth == 2 {
            if checkLeap(year: year) {
                endDay = 29
            } else {
                endDay = 28
            }
        }
        return endDay
    }

    // MARK: 윤년 검사함수
    
    func checkLeap(year: Int) -> Bool {
        var checkValue: Bool = false
        if year % 4 == 0 && (year % 100 != 0 || year % 400 == 0) {
            checkValue = true
        } else {
            checkValue = false
        }
        return checkValue
    }
    
    func todayCheck(time: String) -> Bool {
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        format.locale = Locale(identifier: "kr_KR")
        format.timeZone = TimeZone(abbreviation: "KST")
        if let checkDay = format.date(from: time) {
            let calendar = Calendar.current
            let isToday = calendar.isDateInToday(checkDay)
            return isToday
        } else {
            return false
        }
    }

    // MARK: yyyy-MM-dd'T'HH:mm:ss.SSS'Z' 로 날짜 변환
    
    func getDetailDate(today: Date) -> String {
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        format.locale = Locale(identifier: "kr_KR")
        format.timeZone = TimeZone(abbreviation: "KST")
        let dateString = format.string(from: today)
        return dateString
    }

    // MARK: yyyy-MM-dd 스타일로 날짜 변환
    func getDiaryWriteDate(today: Date) -> String {
        format.dateFormat = "yyyy-MM-dd"
        let dateString = format.string(from: today)
        return dateString
    }

    func getSimpleDate(isoDate: String) -> String {
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let getDate = format.date(from: isoDate) ?? Date()
       // format.dateFormat = "yyyy년 MM월dd일"
        format.dateFormat = "MM월 dd일"
        let dateString = format.string(from: getDate)
        return dateString
    }
    
    func requestDetailDate(isoDate: String) -> Date {
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let getDate = format.date(from: isoDate) ?? Date()
       // format.dateFormat = "yyyy년 MM월dd일"
        format.dateFormat = "MM월 dd일"
        return getDate
        //return dateString
    }

    func delayDate(_ delay: Double, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    func getDelayDetailDate(today: Date, completion: @escaping(String) -> Void) {
        delayDate(0.2) {
            self.format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            self.format.locale = Locale(identifier: "kr_KR")
            self.format.timeZone = TimeZone(secondsFromGMT: 0)
            let dateString = self.format.string(from: today)

            completion(dateString)
        }

    }

    // MARK: 오늘 기준으로 올해 이번달 오늘일자 반환
    func getMonthDayCount(today: Date) -> [Int] {
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        format.locale = Locale(identifier: "kr_KR")
        let calendar = Calendar(identifier: .gregorian)
        let dateFormatter = calendar.dateComponents([.year, .month, .day], from: today)

        if case let (y?, m?, d?) = (dateFormatter.year, dateFormatter.month, dateFormatter.day) {
            print("올해 = \(y) 이번달 = \(m) 오늘 = \(d)")
            if m%2 == 0 {
                if m == 2 {
                    if y % 400 == 0 {
                        return [y, m, 29]
                    } else if y % 100 != 0, y % 4 == 0 {
                        return [y, m, 29]
                    } else {
                        return [y, m, 28]
                    }
                } else {
                    return [y, m, 31]
                }
            } else {
                if m == 7 {
                    return [y, m, 31]
                } else {
                    return [y, m, d]
                }
            }
        }
        return [9999, 12, 31]
    }

    func getLetterStringDate(_ dateString: String) -> String {
        if dateString == "방금전" {
            return dateString
        } else {
            let today = Date()
            format.timeZone = TimeZone(secondsFromGMT: 0)
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let currentDate = format.date(from: dateString) ?? today
            // format.dateFormat = "yyyy년 MM월 dd일 HH:mm"
            format.dateFormat = "yyyy년 MM월 dd일"
            format.locale = Locale(identifier: "ko_KR")
            let date = format.string(from: currentDate)
            return date
        }
    }
    
    // 24시간 이내 게시글 판별
    func yesterdayCompareCheck(with dateString: String) -> Bool {
        let today = Date()
        let yesterDay = today - 86400
        format.locale = Locale(identifier: "ko_kr")
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        guard let postDate = format.date(from: dateString) else { return false }
        return yesterDay > postDate
    }

    func getSimpleDate(_ dateString: String) -> String {
        let today = Date()
        format.dateFormat = "yyyy년 MM월 dd일"

        let convertDate = format.date(from: dateString) ?? today
        let getSimpleDate = format.string(from: convertDate)
        return getSimpleDate
    }

    // MARK: 게시글/댓글 입력날짜 리턴
    func postStateDate(_ isoDate: String) -> String {
        let today = Date()
        let localDate =  Date(timeInterval: TimeInterval(calendar.timeZone.secondsFromGMT()), since: today)
        format.locale = Locale(identifier: "ko_KR")
        format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        format.timeZone = TimeZone(abbreviation: "KST")
        
        var date = format.date(from: isoDate) ?? localDate
        date.addTimeInterval(32400)
        let calendar = Calendar(identifier: .iso8601)

        let calendarC = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: localDate)
        if case let (y?, m?, d?, h?, mi?) = (calendarC.year, calendarC.month, calendarC.day, calendarC.hour, calendarC.minute) {
            //print(y, m, d, h, mi, "날짜0", isoDate, "현재 = \(localDate), \(localIsoDate), 해당날짜 \(date)")
       //     print("인자날짜 = \(isoDate), _localDate =  \(_localDate)")
            if y == 0, m == 0, d == 0, h == 0, mi == 0 {
                return "방금 전"
            } else if y == 0, m == 0, d == 0, h == 0, mi > 0 {
                return "\(mi)분 전"
            } else if y == 0, m == 0, d == 0, h > 0 {
                return "\(h)시간 전"
            } else if y == 0, m == 0, d > 0 {
                if d == 7 {
                    return "7일 전"
                } else if d > 7 {
                    return getSimpleDate(isoDate: isoDate)
                } else  if d < 7 {
                    return "\(d)일 전"
                }
            } else {
                if y == 0 {
                    return getSimpleDate(isoDate: isoDate)
                } else {
                    return "\(getLetterStringDate(isoDate))"
                }
            }
        }
        return "1시간"
    }
}

