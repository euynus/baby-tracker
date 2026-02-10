//
//  AnimationExtensions.swift
//  BabyTracker
//
//  Created on 2026-02-10.
//

import SwiftUI

// MARK: - Custom Animations

extension Animation {
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)
    static let smooth = Animation.easeInOut(duration: 0.3)
}

// MARK: - View Modifiers

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.95
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1.0)
            .animation(.spring, value: configuration.isPressed)
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(
            translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0
        ))
    }
}

struct PulseEffect: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

struct SlideInModifier: ViewModifier {
    let edge: Edge
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .offset(x: isVisible ? 0 : offsetX, y: isVisible ? 0 : offsetY)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                withAnimation(.spring) {
                    isVisible = true
                }
            }
    }
    
    private var offsetX: CGFloat {
        switch edge {
        case .leading: return -300
        case .trailing: return 300
        default: return 0
        }
    }
    
    private var offsetY: CGFloat {
        switch edge {
        case .top: return -300
        case .bottom: return 300
        default: return 0
        }
    }
}

struct FadeInModifier: ViewModifier {
    @State private var opacity: Double = 0
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeIn(duration: 0.5).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

// MARK: - View Extensions

extension View {
    func scaleButton(scale: CGFloat = 0.95) -> some View {
        buttonStyle(ScaleButtonStyle(scale: scale))
    }
    
    func shake(_ animatableData: CGFloat) -> some View {
        modifier(ShakeEffect(animatableData: animatableData))
    }
    
    func pulse() -> some View {
        modifier(PulseEffect())
    }
    
    func slideIn(from edge: Edge = .bottom) -> some View {
        modifier(SlideInModifier(edge: edge))
    }
    
    func fadeIn(delay: Double = 0) -> some View {
        modifier(FadeInModifier(delay: delay))
    }
}

// MARK: - Card Style with Shadow Animation

struct AnimatedCard: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(
                color: .black.opacity(isPressed ? 0.15 : 0.08),
                radius: isPressed ? 12 : 8,
                y: isPressed ? 6 : 4
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring, value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

extension View {
    func animatedCard() -> some View {
        modifier(AnimatedCard())
    }
}

// MARK: - Loading Animation

struct LoadingDotsView: View {
    @State private var animating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Success Checkmark Animation

struct CheckmarkAnimation: View {
    @State private var trimEnd: CGFloat = 0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.green, lineWidth: 3)
                .frame(width: 50, height: 50)
            
            Path { path in
                path.move(to: CGPoint(x: 15, y: 25))
                path.addLine(to: CGPoint(x: 22, y: 32))
                path.addLine(to: CGPoint(x: 35, y: 18))
            }
            .trim(from: 0, to: trimEnd)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            .frame(width: 50, height: 50)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                trimEnd = 1.0
            }
        }
    }
}
