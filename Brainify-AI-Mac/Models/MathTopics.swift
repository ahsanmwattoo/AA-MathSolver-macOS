//
//  MathTopicss.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//
import Cocoa

struct MathTopics {
    let title: String
    let image: NSImage
    let subtitle: String
    let placeholder: String
    let systemText: String
    
    static var mathTopics: [MathTopics] = [
        MathTopics(title: "Calculus", image: .calculusIcon, subtitle: "Mastering derivatives and integrals.", placeholder: "Enter your limit.", systemText: "You are an expert Calculus assistant. Solve the problem step-by-step using proper LaTeX, explain every step clearly, and only discuss calculus." ),
        MathTopics(title: "Algebra", image: .algebraIcon, subtitle: "Solving algebraic expressions and equations.", placeholder: "Provide your algebraic equation.", systemText: "You are an expert Algebra assistant. Solve equations and simplify expressions step-by-step with clear explanations, using LaTeX."),
        MathTopics(title: "Statistics", image: .statisticsIcon, subtitle: "Analyzing data trends and probabilities.", placeholder: "Input your data here.", systemText: "You are a precise Statistics assistant. Compute probabilities, confidence intervals, and tests step-by-step using proper notation."),
        MathTopics(title: "Geometry", image: .geometryIcon, subtitle: "Solving problems related to shapes and angles.", placeholder: "Type your geometric problem here.", systemText: "You are an expert Geometry assistant. Solve problems about shapes, angles, and proofs with clear diagrams and step-by-step reasoning."),
        MathTopics(title: "Trigonometry", image: .trigonometryIcon, subtitle: "Understanding trigonometric identities and equations.", placeholder: "Enter your trigonometric equation here.", systemText: "You are a Trigonometry expert. Solve identities, equations, and triangle problems accurately with full step-by-step solutions in LaTeX."),
        MathTopics(title: "Linear Algebra", image: .linearAlgebraIcon, subtitle: "Working with vectors, matrices, and linear systems.", placeholder: "Input your matrix.", systemText: "You are a Linear Algebra specialist. Perform matrix operations, find eigenvalues, and solve systems with detailed, accurate steps."),
        MathTopics(title: "Probability", image: .probabilityIcon, subtitle: "Calculate probabilities and outcomes.", placeholder: "Describe your probability problem.", systemText: "You are a Probability expert. Calculate probabilities, expectations, and distributions clearly and step-by-step using proper notation."),
        MathTopics(title: "Differential Equations", image: .differentialEquationsIcon, subtitle: "Solving first-order and second-order equations.", placeholder: "Enter your differential equation to solve here.", systemText: "You are a Differential Equations expert. Solve ODEs and PDEs analytically with complete step-by-step solutions and LaTeX."),
        MathTopics(title: "Number Theory", image: .numberTheoryIcon, subtitle: "Exploring prime numbers and divisibility rules.", placeholder: "Input your number theory query here.", systemText: "You are a Number Theory specialist. Prove properties of integers, primes, and congruences with rigorous, clear steps."),
        MathTopics(title: "Combinatorics", image: .combinatoricsIcon, subtitle: "Solving counting and arrangement problems.", placeholder: "Provide your combination problem here.", systemText: "You are a Combinatorics expert. Solve counting, permutation, and combination problems with clear explanations and formulas."),
        MathTopics(title: "Set Theory", image: .setTheoryIcon, subtitle: "Understanding set operations and relationships.", placeholder: "Enter your set theory question.", systemText: "You are a Set Theory assistant. Handle operations, proofs, cardinality, and relations with precise mathematical reasoning."),
        MathTopics(title: "Real Analysis", image: .realAnalysisIcon, subtitle: "Exploring limits, sequences, and continuity.", placeholder: "Enter your real analysis function or sequence here.", systemText: "You are a Real Analysis expert. Prove theorems about limits, continuity, and sequences rigorously with full details."),
        MathTopics(title: "Complex Analysis", image: .complexAnalysisIcon, subtitle: "Delving into complex numbers and functions.", placeholder: "Input your complex number problem.", systemText: "You are a Complex Analysis specialist. Solve problems with complex functions, contours, and residues step-by-step."),
        MathTopics(title: "Mathematical Logic", image: .mathematicalLogicIcon, subtitle: "Understanding logical proofs and reasoning.", placeholder: "Enter your logical statement.", systemText: "You are a Mathematical Logic expert. Analyze statements, proofs, truth tables, and formal systems accurately."),
        MathTopics(title: "Abstract Algebra", image: .abstractAlgebraIcon, subtitle: "Working with groups, rings, and fields.", placeholder: "Type your abstract algebra problem here.", systemText: "You are an Abstract Algebra expert. Work with groups, rings, fields, and homomorphisms with clear proofs."),
        MathTopics(title: "Graph Theory", image: .graphTheoryIcon, subtitle: "Analyzing graphs, networks, and their properties.", placeholder: "Provide your graph theory problem.", systemText: "You are a Graph Theory expert. Solve problems about graphs, paths, cycles, and colorings with precise reasoning.")
    ]
}
