//
//  AnimationManager.swift
//  MartiCase
//
//  Created by Ömer Firat on 22.03.2025.
//

import UIKit
import Lottie

// AnimationManager sınıfı
class AnimationManager {

    // Lottie animasyonunu başlatma
    static func startLottieAnimation(on view: UIView, animationName: String, completion: @escaping () -> Void) {
        let animationView = createLottieAnimationView(named: animationName)
        
        // Animasyonu ekle
        view.addSubview(animationView)
        
        // Animasyonu başlat
        playLottieAnimation(animationView) {
            // Animasyon tamamlandığında completion callback'ini çağır
            completion()
        }
        
        // Animasyonu büyütme
        animateLottieViewGrowth(animationView)
    }
    
    // Lottie animasyonunun görselini oluştur
    private static func createLottieAnimationView(named animationName: String) -> LottieAnimationView {
        let animationView = LottieAnimationView(name: animationName)
        animationView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)  // Başlangıç boyutu
        animationView.center = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)  // Ekranın ortasına yerleştir
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 1.0
        
        // Render motorunu manuel olarak ayarla
        let configuration = LottieConfiguration(renderingEngine: .mainThread)
        animationView.configuration = configuration
        
        return animationView
    }
    
    // Lottie animasyonunu oynat
    private static func playLottieAnimation(_ animationView: LottieAnimationView, completion: @escaping () -> Void) {
        animationView.play { (finished) in
            if finished {
                completion()
            }
        }
    }
    
    // Animasyonu büyütme
    private static func animateLottieViewGrowth(_ animationView: LottieAnimationView) {
        UIView.animate(withDuration: 3.0, animations: {
            animationView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)  // Ekranı kaplayacak şekilde büyüt
        }) { _ in
            // Büyütme tamamlandığında fade-out efekti uygula
            applyFadeOutEffect(to: animationView)
        }
    }
    
    // Fade-out efekti uygula
    private static func applyFadeOutEffect(to animationView: LottieAnimationView) {
        UIView.animate(withDuration: 1.0, animations: {
            animationView.alpha = 0  // Fade-out efekti
        })
    }
}
