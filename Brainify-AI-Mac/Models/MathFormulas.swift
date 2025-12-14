//
//  MathFormulas.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//

struct MathFormulas {
    let topic: String
    let formulaNames: [Formula]
    var isCollapsed: Bool = true
    
    static var allTopics: [MathFormulas] = [
        MathFormulas(topic: "Complex Function", formulaNames: Formula.complexFunction, isCollapsed: true),
        MathFormulas(topic: "Power Function", formulaNames: Formula.powerFunction, isCollapsed: true),
        MathFormulas(topic: "Sequence of Numbers", formulaNames: Formula.sequencePOfNumbers, isCollapsed: true),
        MathFormulas(topic: "Trigonometric Function", formulaNames: Formula.trigonometricFunction, isCollapsed: true),
        MathFormulas(topic: "Inverse Trigonometric Function", formulaNames: Formula.inverseTrigonometricFunction, isCollapsed: true),
        MathFormulas(topic: "Hyperbolic Function", formulaNames: Formula.hyperbolicFunction, isCollapsed: true),
        MathFormulas(topic: "Inverse Hyperbolic Function", formulaNames: Formula.inverseHyperbolicFunction, isCollapsed: true),
        MathFormulas(topic: "Limit", formulaNames: Formula.limit, isCollapsed: true),
        MathFormulas(topic: "Derivatives", formulaNames: Formula.indefiniteIntegral, isCollapsed: true),
        MathFormulas(topic: "Indefinite Integral", formulaNames: Formula.indefiniteIntegral, isCollapsed: true),
        MathFormulas(topic: "Definite Integral", formulaNames: Formula.definiteIntegral, isCollapsed: true),
        MathFormulas(topic: "Rational Functions", formulaNames: Formula.rationalFunction, isCollapsed: true),
        MathFormulas(topic: "Logarithmic Functions", formulaNames: Formula.logarithms, isCollapsed: true),
        MathFormulas(topic: "Exponential Function", formulaNames: Formula.exponential, isCollapsed: true)
    ]
}

struct Formula: Equatable {
    let name: String
    let formula: String
    
    static var complexFunction: [Formula] = [
        Formula(name: "Euler's Formula:", formula: "e^{ix} = \\cos x + i \\sin x"),
        
        Formula(name: "Complex Number in Polar Form:", formula: "z = r (\\cos \\theta + i \\sin \\theta)"),
        
        Formula(name: "Addition of Complex Numbers:", formula: "(a + bi) + (c + di) = (a + c) + (b + d)i"),
        
        Formula(name: "Multiplication of Complex Numbers:", formula: "(a + bi)(c + di) = (ac - bd) + (ad + bc)i"),
        
        Formula(name: "Modulus of a Complex Number:", formula: "|z| = \\sqrt{a^2 + b^2}"),
        
        Formula(name: "Argument of a Complex Number:", formula: "\\arg(z) = \\tan^{-1} \\left( \\frac{b}{a} \\right)"),
        
        Formula(name: "Complex Conjugate:", formula: "\\bar{z} = a - bi")
    ]
    
    static var powerFunction: [Formula] = [
        Formula(name: "General Power Function:", formula: "f(x)=axnf(x) = a x^nf(x)=axn"),
        Formula(name: "Power Function with Horizontal Shift:", formula: "f(x)=a(x−h)n+kf(x) = a (x - h)^n + kf(x)=a(x−h)n+k"),
        Formula(name: "Power Function with Negative Exponent:", formula: "f(x)=axnf(x) = \\frac{a}{x^n}f(x)=xna"),
        Formula(name: "Power Law Growth:", formula: "f(x)=a⋅xbf(x) = a \\cdot x^bf(x)=a⋅xb"),
        Formula(name: "Derivative of Power Function:", formula: "f′(x)=anxn−1f'(x) = a n x^{n-1}f′(x)=anxn−1")
    ]
    
    static var sequencePOfNumbers: [Formula] = [
        Formula(name: "Arithmetic Sequence:", formula: "an=a1+(n−1)⋅da_n = a_1 + (n-1) \\cdot dan​=a1​+(n−1)⋅d"),
        Formula(name: "Geometric Sequence:", formula: "an=a1⋅rn−1a_n = a_1 \\cdot r^{n-1}an​=a1​⋅rn−1"),
        Formula(name: "Sum of an Arithmetic Sequence:", formula: "Sn=n2⋅(a1+an)S_n = \\frac{n}{2} \\cdot (a_1 + a_n)Sn​=2n​⋅(a1​+an​)"),
        Formula(name: "Sum of a Geometric Sequence:", formula: "Sn=a1⋅1−rn1−r(for r≠1)S_n = a_1 \\cdot \\frac{1 - r^n}{1 - r} \\quad \\text{(for } r \\neq 1)Sn​=a1​⋅1−r1−rn​(for r=1)"),
        Formula(name: "Recursive Sequence:", formula: "an=f(an−1)a_n = f(a_{n-1})an​=f(an−1​)")
    ]
    static var trigonometricFunction: [Formula] = [
        Formula(name: "Sine Function:", formula: "f(x)=sin⁡(x)f(x) = \\sin(x)f(x)=sin(x)"),
        Formula(name: "Cosine Function:", formula: "f(x)=cos⁡(x)f(x) = \\cos(x)f(x)=cos(x)"),
        Formula(name: "Tangent Function:", formula: "f(x)=tan⁡(x)f(x) = \\tan(x)f(x)=tan(x)"),
        Formula(name: "Secant Function:", formula: "f(x)=sec⁡(x)=1cos⁡(x)f(x) = \\sec(x) = \\frac{1}{\\cos(x)}f(x)=sec(x)=cos(x)1"),
        Formula(name: "Cosecant Function:", formula: "f(x)=csc⁡(x)=1sin⁡(x)f(x) = \\csc(x) = \\frac{1}{\\sin(x)}f(x)=csc(x)=sin(x)1"),
        Formula(name: "Cotangent Function:", formula: "f(x)=cot⁡(x)=1tan⁡(x)f(x) = \\cot(x) = \\frac{1}{\\tan(x)}f(x)=cot(x)=tan(x)1")
    ]
    
    static var inverseTrigonometricFunction: [Formula] = [
        Formula(name: "Inverse Sine:", formula: "sin⁡−1(x)=ywheresin⁡(y)=x\\sin^{-1}(x) = y \\quad \\text{where} \\quad \\sin(y) = xsin−1(x)=ywheresin(y)=x"),
        Formula(name: "Inverse Cosine:", formula: "cos⁡−1(x)=ywherecos⁡(y)=x\\cos^{-1}(x) = y \\quad \\text{where} \\quad \\cos(y) = xcos−1(x)=ywherecos(y)=x"),
        Formula(name: "Inverse Tangent:", formula: "tan⁡−1(x)=ywheretan⁡(y)=x\\tan^{-1}(x) = y \\quad \\text{where} \\quad \\tan(y) = xtan−1(x)=ywheretan(y)=x"),
        Formula(name: "Inverse Secant:", formula: "sec⁡−1(x)=ywheresec⁡(y)=x\\sec^{-1}(x) = y \\quad \\text{where} \\quad \\sec(y) = xsec−1(x)=ywheresec(y)=x"),
        Formula(name: "Inverse Cosecant:", formula: "csc⁡−1(x)=ywherecsc⁡(y)=x\\csc^{-1}(x) = y \\quad \\text{where} \\quad \\csc(y) = xcsc−1(x)=ywherecsc(y)=x"),
        Formula(name: "Inverse Cotangent:", formula: "cot⁡−1(x)=ywherecot⁡(y)=x\\cot^{-1}(x) = y \\quad \\text{where} \\quad \\cot(y) = xcot−1(x)=ywherecot(y)=x")
    ]
    
    static var hyperbolicFunction: [Formula] = [
        Formula(name: "Hyperbolic Sine:", formula: "sinh⁡(x)=ex−e−x2\\sinh(x) = \\frac{e^x - e^{-x}}{2}sinh(x)=2ex−e−x"),
        Formula(name: "Hyperbolic Cosine:", formula: "cosh⁡(x)=ex+e−x2\\cosh(x) = \\frac{e^x + e^{-x}}{2}cosh(x)=2ex+e−x"),
        Formula(name: "Hyperbolic Tangent:", formula: "tanh⁡(x)=sinh⁡(x)cosh⁡(x)\\tanh(x) = \\frac{\\sinh(x)}{\\cosh(x)}tanh(x)=cosh(x)sinh(x)"),
        Formula(name: "Hyperbolic Secant:", formula: "sech(x)=1cosh⁡(x)\\text{sech}(x) = \\frac{1}{\\cosh(x)}sech(x)=cosh(x)1"),
        Formula(name: "Hyperbolic Cosecant:", formula: "csch(x)=1sinh⁡(x)\\text{csch}(x) = \\frac{1}{\\sinh(x)}csch(x)=sinh(x)1"),
        Formula(name: "Hyperbolic Cotangent:", formula: "coth(x)=cosh⁡(x)sinh⁡(x)\\text{coth}(x) = \\frac{\\cosh(x)}{\\sinh(x)}coth(x)=sinh(x)cosh(x)"),
    ]
    
    static var inverseHyperbolicFunction: [Formula] = [
        Formula(name: "Inverse Hyperbolic Sine:", formula: "sinh⁡−1(x)=ln⁡(x+x2+1)\\sinh^{-1}(x) = \\ln(x + \\sqrt{x^2 + 1})sinh−1(x)=ln(x+x2+1​)"),
        Formula(name: "Inverse Hyperbolic Cosine:", formula: "cosh⁡−1(x)=ln⁡(x+x2−1)\\cosh^{-1}(x) = \\ln(x + \\sqrt{x^2 - 1})cosh−1(x)=ln(x+x2−1​)"),
        Formula(name: "Inverse Hyperbolic Tangent:", formula: "tanh⁡−1(x)=12ln⁡(1+x1−x)\\tanh^{-1}(x) = \\frac{1}{2} \\ln\\left(\\frac{1 + x}{1 - x}\\right)tanh−1(x)=21​ln(1−x1+x​)"),
        Formula(name: "Inverse Hyperbolic Secant:", formula: "sech−1(x)=ln⁡(1x+1x2−1)\\text{sech}^{-1}(x) = \\ln\\left(\\frac{1}{x} + \\sqrt{\\frac{1}{x^2} - 1}\\right)sech−1(x)=ln(x1​+x21​−1​)"),
        Formula(name: "Inverse Hyperbolic Cosecant:", formula: "csch−1(x)=ln⁡(1x+1x2+1)\\text{csch}^{-1}(x) = \\ln\\left(\\frac{1}{x} + \\sqrt{\\frac{1}{x^2} + 1}\\right)csch−1(x)=ln(x1​+x21​+1​)"),
        Formula(name: "Inverse Hyperbolic Cotangent:", formula: "coth−1(x)=12ln⁡(x+1x−1)\\text{coth}^{-1}(x) = \\frac{1}{2} \\ln\\left(\\frac{x + 1}{x - 1}\\right)coth−1(x)=21​ln(x−1x+1​)"),
    ]
    
    static var limit: [Formula] = [
        Formula(name: "Limit of a Function as x Approaches a:", formula: "\\lim_{x \\to a} f(x)"),
        
        Formula(name: "Limit of a Sequence:", formula: "\\lim_{n \\to \\infty} a_n"),
        
        Formula(name: "Indeterminate Form:", formula: "\\lim_{x \\to 0} \\frac{\\sin x}{x} = 1"),
        
        Formula(name: "Limit of Rational Functions:", formula: "\\lim_{x \\to \\infty} \\frac{P(x)}{Q(x)} \\quad (\\text{where } P \\text{ and } Q \\text{ are polynomials})")
    ]
    
    static var derivative: [Formula] = [
        Formula(name: "Derivative of Power Function:", formula: "f'(x) = a \\cdot n \\cdot x^{n-1}"),
        Formula(name: "Product Rule:", formula: "(f \\cdot g)' = f' \\cdot g + f \\cdot g'"),
        Formula(name: "Quotient Rule:", formula: "\\left( \\frac{f}{g} \\right)' = \\frac{f' \\cdot g - f \\cdot g'}{g^2}"),
        Formula(name: "Chain Rule:", formula: "\\frac{d}{dx} f(g(x)) = f'(g(x)) \\cdot g'(x)")
    ]
    
    static var indefiniteIntegral: [Formula] = [
        Formula(name: "Indefinite Integral of Power Function:", formula: "\\int x^n \\, dx = \\frac{x^{n+1}}{n+1} + C"),
        
        Formula(name: "Indefinite Integral of Exponential Function:", formula: "\\int e^x \\, dx = e^x + C"),
        
        Formula(name: "Indefinite Integral of Trigonometric Functions:", formula: """
            \\int \\sin x \\, dx = -\\cos x + C \\\\
            \\int \\cos x \\, dx = \\sin x + C
            """),
        
        Formula(name: "Indefinite Integral of Rational Function:", formula: "\\int \\frac{1}{x} \\, dx = \\ln |x| + C")
    ]
    
    static var definiteIntegral: [Formula] = [
        Formula(name: "Definite Integral:", formula: "∫abf(x) dx\\int_a^b f(x) \\, dx∫ab​f(x)dx"),
        Formula(name: "Fundamental Theorem of Calculus:", formula: "∫abf(x) dx=F(b)−F(a)\\int_a^b f(x) \\, dx = F(b) - F(a)∫ab​f(x)dx=F(b)−F(a)"),
        Formula(name: "Area Under a Curve:", formula: "A=∫abf(x) dxA = \\int_a^b f(x) \\, dxA=∫ab​f(x)dx")
    ]
    
    static var rationalFunction: [Formula] = [
        Formula(name: "General Rational Function:", formula: "f(x) = \\frac{P(x)}{Q(x)}"),
        
        Formula(name: "Vertical Asymptote:", formula: "x = a \\quad (\\text{if } Q(x) = 0)"),
        
        Formula(name: "Horizontal Asymptote:", formula: """
            \\begin{cases}
            y = 0 & \\text{if degree of } P(x) < Q(x) \\\\
            y = \\frac{a}{b} & \\text{if degree of } P(x) = Q(x)
            \\end{cases}
            """),
        
        Formula(name: "Oblique Asymptote:", formula: "\\text{if degree of } P(x) = \\text{degree of } Q(x) + 1, \\quad y = \\frac{P(x)}{Q(x)}"),
        
        Formula(name: "Simplifying Rational Functions:", formula: "f(x) = \\frac{P(x)}{Q(x)} \\quad (\\text{can be simplified by canceling common factors in } P(x) \\text{ and } Q(x))"),
        
        Formula(name: "Horizontal Asymptote for Large x:", formula: "f(x) = \\frac{a}{x^n}, \\quad \\text{as } x \\to \\infty, \\, f(x) \\to 0"),
        
        Formula(name: "End Behavior:", formula: "\\text{if } \\deg(P) > \\deg(Q), \\quad \\text{the function has an oblique asymptote}"),
        
        Formula(name: "Hole in the Graph:", formula: "x = a \\quad (\\text{if } P(x) \\text{ and } Q(x) \\text{ share a common factor})")
    ]
    static var logarithms: [Formula] = [
        Formula(name: "General Logarithmic Function:", formula: "f(x)=a⋅log⁡b(x−h)+kf(x) = a \\cdot \\log_b(x - h) + kf(x)=a⋅logb​(x−h)+k"),
        Formula(name: "Change of Base Formula:", formula: "log⁡b(x)=log⁡k(x)log⁡k(b)\\log_b(x) = \\frac{\\log_k(x)}{\\log_k(b)}logb​(x)=logk​(b)logk​(x)"),
        Formula(name: "Solving Logarithmic Equations:", formula: "log⁡b(x)=y⇒x=by\\log_b(x) = y \\quad \\Rightarrow \\quad x = b^ylogb​(x)=y⇒x=by"),
        Formula(name: "Logarithmic Growth:", formula: "f(x)=a⋅log⁡b(x)f(x) = a \\cdot \\log_b(x)f(x)=a⋅logb​(x)"),
        Formula(name: "Logarithmic Decay:", formula: "f(x)=−a⋅log⁡b(x)f(x) = -a \\cdot \\log_b(x)f(x)=−a⋅logb​(x)"),
        Formula(name: "Product Property of Logarithms:", formula: "log⁡b(xy)=log⁡b(x)+log⁡b(y)\\log_b(xy) = \\log_b(x) + \\log_b(y)logb​(xy)=logb​(x)+logb​(y)"),
        Formula(name: "Quotient Property of Logarithms:", formula: "log⁡b(xy)=log⁡b(x)−log⁡b(y)\\log_b\\left(\\frac{x}{y}\\right) = \\log_b(x) - \\log_b(y)logb​(yx​)=logb​(x)−logb​(y)"),
        Formula(name: "Power Property of Logarithms:", formula: "log⁡b(xn)=n⋅log⁡b(x)\\log_b(x^n) = n \\cdot \\log_b(x)logb​(xn)=n⋅logb​(x)")
    ]
    
    static var exponential: [Formula] = [
        Formula(name: "General Exponential Function (with horizontal shift, stretch/compression, and reflection):", formula: "f(x) = a \\cdot e^{b(x - h)} + k"),
        Formula(name: "Exponential Growth/Decay with Different Bases:", formula: "f(x) = a \\cdot b^{(x - h)} + k"),
        Formula(name: "Exponential Equation in Terms of Logarithms:", formula: "x = \\log_b(y)"),
        Formula(name: "Continuous Compounding Formula (Finance):", formula: "A = P e^{rt}"),
        Formula(name: "Solving Exponential Equations:", formula: "a^{f(x)} = b^{g(x)}"),
        Formula(name: "Exponential Function with Different Growth Rates:", formula: "f(x) = a_1 \\cdot e^{b_1 x} + a_2 \\cdot e^{b_2 x}"),
        Formula(name: "Differential Equation for Exponential Growth/Decay:", formula: "\\frac{dy}{dt} = k \\cdot y"),
        Formula(name: "Exponential Decay with Half-Life:", formula: "N(t) = N_0 \\cdot e^{-\\frac{t}{T_{1/2}}}")
    ]
}
