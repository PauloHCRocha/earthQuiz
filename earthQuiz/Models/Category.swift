//
//  Category.swift
//  earthQuiz
//
//  Created by Claude on 2025-11-05.
//

import Foundation

enum Category: String, CaseIterable, Identifiable {
    case population = "População"
    case football = "Futebol"
    case tourism = "Turismo"
    case gdp = "PIB"
    case forest = "Floresta"
    case area = "Área"
    case lifeExpectancy = "Expectativa de Vida"
    case education = "Educação"
    case technology = "Tecnologia"
    case renewable = "Energia Renovável"
    case happiness = "Felicidade"
    case exports = "Exportações"
    case olympics = "Medalhas Olímpicas"
    case internet = "Internet"
    case healthcare = "Saúde"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .population: return "person.3.fill"
        case .football: return "soccerball"
        case .tourism: return "airplane"
        case .gdp: return "dollarsign.circle.fill"
        case .forest: return "tree.fill"
        case .area: return "map.fill"
        case .lifeExpectancy: return "heart.fill"
        case .education: return "book.fill"
        case .technology: return "laptopcomputer"
        case .renewable: return "bolt.fill"
        case .happiness: return "face.smiling.fill"
        case .exports: return "shippingbox.fill"
        case .olympics: return "medal.fill"
        case .internet: return "wifi"
        case .healthcare: return "cross.case.fill"
        }
    }

    var description: String {
        switch self {
        case .population: return "Ranking de população mundial"
        case .football: return "Ranking FIFA de futebol"
        case .tourism: return "Ranking de turismo internacional"
        case .gdp: return "Ranking de PIB per capita"
        case .forest: return "Ranking de área florestal"
        case .area: return "Ranking de área territorial"
        case .lifeExpectancy: return "Ranking de expectativa de vida"
        case .education: return "Ranking de qualidade educacional"
        case .technology: return "Ranking de inovação tecnológica"
        case .renewable: return "Ranking de energia renovável"
        case .happiness: return "Ranking mundial de felicidade"
        case .exports: return "Ranking de volume de exportações"
        case .olympics: return "Ranking de medalhas olímpicas"
        case .internet: return "Ranking de penetração de internet"
        case .healthcare: return "Ranking de qualidade de saúde"
        }
    }
}
