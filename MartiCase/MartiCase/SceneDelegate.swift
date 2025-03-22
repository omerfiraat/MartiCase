//
//  SceneDelegate.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - Scene Setup

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        
        let launchVC = createLaunchViewController()
        window?.rootViewController = launchVC
        window?.makeKeyAndVisible()
        
        AnimationManager.startLottieAnimation(on: launchVC.view, animationName: "launchAnimation") {
            self.transitionToMainScreen()
        }
    }

    // MARK: - Helper Methods

    private func createLaunchViewController() -> UIViewController {
        let launchVC = UIViewController()
        launchVC.view.backgroundColor = .white
        return launchVC
    }

    private func transitionToMainScreen() {
        let mainVC = MapViewController()
        let navController = UINavigationController(rootViewController: mainVC)
        navController.navigationBar.tintColor = .systemBlue
        self.window?.rootViewController = navController
    }

    // MARK: - Scene Lifecycle Methods

    func sceneDidDisconnect(_ scene: UIScene) { }
    func sceneDidBecomeActive(_ scene: UIScene) { }
    func sceneWillResignActive(_ scene: UIScene) { }
    func sceneWillEnterForeground(_ scene: UIScene) { }
    func sceneDidEnterBackground(_ scene: UIScene) { }
}
