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
        case .population:
            return "Número total de habitantes do país"
        case .football:
            return "Ranking FIFA oficial de seleções nacionais"
        case .tourism:
            return "Número de chegadas de turistas internacionais por ano"
        case .gdp:
            return "PIB per capita (PPP) - riqueza média por habitante"
        case .forest:
            return "Área total de floresta em quilômetros quadrados"
        case .area:
            return "Tamanho territorial total do país"
        case .lifeExpectancy:
            return "Expectativa de vida média ao nascer"
        case .education:
            return "Qualidade do sistema educacional (PISA)"
        case .technology:
            return "Índice de Inovação Global (tecnologia e P&D)"
        case .renewable:
            return "Percentagem de energia renovável no consumo total"
        case .happiness:
            return "Índice de Felicidade Mundial (ONU)"
        case .exports:
            return "Volume total de exportações em dólares"
        case .olympics:
            return "Total de medalhas olímpicas conquistadas (histórico)"
        case .internet:
            return "Taxa de penetração de internet (% da população)"
        case .healthcare:
            return "Qualidade do sistema de saúde e acesso a cuidados"
        }
    }
}
