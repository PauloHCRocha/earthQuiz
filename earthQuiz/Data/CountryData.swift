//
//  CountryData.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import Foundation

class CountryData {
    static let shared = CountryData()

    let countries: [Country] = [
        // Top countries with realistic rankings
        Country(id: "BR", name: "Brasil", flag: "🇧🇷", rankings: [
            .population: 7,
            .football: 1,
            .tourism: 45,
            .gdp: 87,
            .forest: 2,
            .area: 5,
            .lifeExpectancy: 78,
            .education: 65,
            .technology: 48,
            .renewable: 12
        ]),
        Country(id: "PT", name: "Portugal", flag: "🇵🇹", rankings: [
            .population: 89,
            .football: 8,
            .tourism: 18,
            .gdp: 41,
            .forest: 78,
            .area: 111,
            .lifeExpectancy: 22,
            .education: 30,
            .technology: 35,
            .renewable: 8
        ]),
        Country(id: "US", name: "Estados Unidos", flag: "🇺🇸", rankings: [
            .population: 3,
            .football: 25,
            .tourism: 3,
            .gdp: 8,
            .forest: 4,
            .area: 3,
            .lifeExpectancy: 46,
            .education: 15,
            .technology: 2,
            .renewable: 45
        ]),
        Country(id: "CN", name: "China", flag: "🇨🇳", rankings: [
            .population: 1,
            .football: 78,
            .tourism: 4,
            .gdp: 67,
            .forest: 5,
            .area: 4,
            .lifeExpectancy: 68,
            .education: 28,
            .technology: 11,
            .renewable: 7
        ]),
        Country(id: "IN", name: "Índia", flag: "🇮🇳", rankings: [
            .population: 2,
            .football: 102,
            .tourism: 22,
            .gdp: 142,
            .forest: 10,
            .area: 7,
            .lifeExpectancy: 125,
            .education: 92,
            .technology: 43,
            .renewable: 18
        ]),
        Country(id: "DE", name: "Alemanha", flag: "🇩🇪", rankings: [
            .population: 19,
            .football: 11,
            .tourism: 9,
            .gdp: 18,
            .forest: 58,
            .area: 63,
            .lifeExpectancy: 28,
            .education: 8,
            .technology: 4,
            .renewable: 15
        ]),
        Country(id: "FR", name: "França", flag: "🇫🇷", rankings: [
            .population: 22,
            .football: 3,
            .tourism: 1,
            .gdp: 24,
            .forest: 44,
            .area: 49,
            .lifeExpectancy: 19,
            .education: 12,
            .technology: 16,
            .renewable: 28
        ]),
        Country(id: "GB", name: "Reino Unido", flag: "🇬🇧", rankings: [
            .population: 21,
            .football: 4,
            .tourism: 7,
            .gdp: 22,
            .forest: 112,
            .area: 80,
            .lifeExpectancy: 26,
            .education: 6,
            .technology: 9,
            .renewable: 52
        ]),
        Country(id: "IT", name: "Itália", flag: "🇮🇹", rankings: [
            .population: 25,
            .football: 7,
            .tourism: 5,
            .gdp: 28,
            .forest: 72,
            .area: 72,
            .lifeExpectancy: 8,
            .education: 24,
            .technology: 28,
            .renewable: 24
        ]),
        Country(id: "ES", name: "Espanha", flag: "🇪🇸", rankings: [
            .population: 30,
            .football: 10,
            .tourism: 2,
            .gdp: 32,
            .forest: 54,
            .area: 52,
            .lifeExpectancy: 5,
            .education: 22,
            .technology: 30,
            .renewable: 11
        ]),
        Country(id: "JP", name: "Japão", flag: "🇯🇵", rankings: [
            .population: 11,
            .football: 18,
            .tourism: 12,
            .gdp: 26,
            .forest: 52,
            .area: 62,
            .lifeExpectancy: 2,
            .education: 4,
            .technology: 3,
            .renewable: 35
        ]),
        Country(id: "KR", name: "Coreia do Sul", flag: "🇰🇷", rankings: [
            .population: 28,
            .football: 23,
            .tourism: 38,
            .gdp: 29,
            .forest: 98,
            .area: 109,
            .lifeExpectancy: 11,
            .education: 2,
            .technology: 1,
            .renewable: 48
        ]),
        Country(id: "CA", name: "Canadá", flag: "🇨🇦", rankings: [
            .population: 38,
            .football: 41,
            .tourism: 15,
            .gdp: 21,
            .forest: 3,
            .area: 2,
            .lifeExpectancy: 17,
            .education: 7,
            .technology: 14,
            .renewable: 3
        ]),
        Country(id: "AU", name: "Austrália", flag: "🇦🇺", rankings: [
            .population: 56,
            .football: 26,
            .tourism: 27,
            .gdp: 12,
            .forest: 18,
            .area: 6,
            .lifeExpectancy: 9,
            .education: 10,
            .technology: 18,
            .renewable: 22
        ]),
        Country(id: "MX", name: "México", flag: "🇲🇽", rankings: [
            .population: 10,
            .football: 15,
            .tourism: 6,
            .gdp: 78,
            .forest: 12,
            .area: 14,
            .lifeExpectancy: 88,
            .education: 72,
            .technology: 58,
            .renewable: 19
        ]),
        Country(id: "AR", name: "Argentina", flag: "🇦🇷", rankings: [
            .population: 32,
            .football: 2,
            .tourism: 52,
            .gdp: 61,
            .forest: 28,
            .area: 8,
            .lifeExpectancy: 62,
            .education: 48,
            .technology: 52,
            .renewable: 26
        ]),
        Country(id: "RU", name: "Rússia", flag: "🇷🇺", rankings: [
            .population: 9,
            .football: 35,
            .tourism: 48,
            .gdp: 68,
            .forest: 1,
            .area: 1,
            .lifeExpectancy: 102,
            .education: 32,
            .technology: 38,
            .renewable: 62
        ]),
        Country(id: "ZA", name: "África do Sul", flag: "🇿🇦", rankings: [
            .population: 25,
            .football: 58,
            .tourism: 35,
            .gdp: 92,
            .forest: 82,
            .area: 25,
            .lifeExpectancy: 152,
            .education: 98,
            .technology: 72,
            .renewable: 42
        ]),
        Country(id: "NG", name: "Nigéria", flag: "🇳🇬", rankings: [
            .population: 6,
            .football: 38,
            .tourism: 112,
            .gdp: 158,
            .forest: 22,
            .area: 32,
            .lifeExpectancy: 178,
            .education: 142,
            .technology: 102,
            .renewable: 82
        ]),
        Country(id: "EG", name: "Egito", flag: "🇪🇬", rankings: [
            .population: 14,
            .football: 36,
            .tourism: 23,
            .gdp: 118,
            .forest: 158,
            .area: 30,
            .lifeExpectancy: 108,
            .education: 88,
            .technology: 92,
            .renewable: 58
        ]),
        Country(id: "SE", name: "Suécia", flag: "🇸🇪", rankings: [
            .population: 91,
            .football: 22,
            .tourism: 42,
            .gdp: 11,
            .forest: 32,
            .area: 56,
            .lifeExpectancy: 7,
            .education: 5,
            .technology: 6,
            .renewable: 2
        ]),
        Country(id: "NO", name: "Noruega", flag: "🇳🇴", rankings: [
            .population: 118,
            .football: 48,
            .tourism: 58,
            .gdp: 4,
            .forest: 48,
            .area: 68,
            .lifeExpectancy: 13,
            .education: 3,
            .technology: 12,
            .renewable: 1
        ]),
        Country(id: "CH", name: "Suíça", flag: "🇨🇭", rankings: [
            .population: 101,
            .football: 13,
            .tourism: 28,
            .gdp: 2,
            .forest: 88,
            .area: 136,
            .lifeExpectancy: 3,
            .education: 1,
            .technology: 5,
            .renewable: 16
        ]),
        Country(id: "NL", name: "Países Baixos", flag: "🇳🇱", rankings: [
            .population: 68,
            .football: 6,
            .tourism: 32,
            .gdp: 14,
            .forest: 128,
            .area: 134,
            .lifeExpectancy: 18,
            .education: 11,
            .technology: 8,
            .renewable: 21
        ]),
        Country(id: "BE", name: "Bélgica", flag: "🇧🇪", rankings: [
            .population: 82,
            .football: 5,
            .tourism: 36,
            .gdp: 19,
            .forest: 102,
            .area: 140,
            .lifeExpectancy: 25,
            .education: 18,
            .technology: 17,
            .renewable: 38
        ]),
        Country(id: "GR", name: "Grécia", flag: "🇬🇷", rankings: [
            .population: 86,
            .football: 42,
            .tourism: 11,
            .gdp: 52,
            .forest: 68,
            .area: 97,
            .lifeExpectancy: 31,
            .education: 42,
            .technology: 48,
            .renewable: 32
        ]),
        Country(id: "TR", name: "Turquia", flag: "🇹🇷", rankings: [
            .population: 18,
            .football: 31,
            .tourism: 8,
            .gdp: 58,
            .forest: 42,
            .area: 37,
            .lifeExpectancy: 82,
            .education: 58,
            .technology: 42,
            .renewable: 28
        ]),
        Country(id: "TH", name: "Tailândia", flag: "🇹🇭", rankings: [
            .population: 20,
            .football: 98,
            .tourism: 10,
            .gdp: 92,
            .forest: 38,
            .area: 51,
            .lifeExpectancy: 78,
            .education: 68,
            .technology: 52,
            .renewable: 42
        ]),
        Country(id: "ID", name: "Indonésia", flag: "🇮🇩", rankings: [
            .population: 4,
            .football: 148,
            .tourism: 26,
            .gdp: 128,
            .forest: 8,
            .area: 15,
            .lifeExpectancy: 118,
            .education: 102,
            .technology: 68,
            .renewable: 14
        ]),
        Country(id: "MY", name: "Malásia", flag: "🇲🇾", rankings: [
            .population: 45,
            .football: 132,
            .tourism: 34,
            .gdp: 62,
            .forest: 24,
            .area: 67,
            .lifeExpectancy: 72,
            .education: 38,
            .technology: 32,
            .renewable: 36
        ]),
        Country(id: "SG", name: "Singapura", flag: "🇸🇬", rankings: [
            .population: 115,
            .football: 158,
            .tourism: 24,
            .gdp: 3,
            .forest: 172,
            .area: 178,
            .lifeExpectancy: 4,
            .education: 9,
            .technology: 7,
            .renewable: 92
        ])
    ]

    private init() {}

    func randomCountry() -> Country {
        return countries.randomElement()!
    }

    func randomCountries(_ count: Int) -> [Country] {
        return countries.shuffled().prefix(count).map { $0 }
    }
}
