//
//  Coordinator.swift
//  Manager
//
//  Created by Matteo Gentili on 09/10/23.
//

import SwiftUI
import UIKit
import Combine

open class Coordinator<MainRouter: NavigationRouter>: ObservableObject {
    
    public var navigationController: UINavigationController
    public let startingRoute: MainRouter?
    public var stackRouting = [any NavigationRouter]() // aggiungere il router quando viene richiamato il metodo show per registrare la navigazione
    
    
    @Published var dbEnv: DatabaseEnvironment = DatabaseEnvironment()
    var cancellableDb : AnyCancellable?
    
    @Published var loginEnv: LoginViewModel = LoginViewModel()
    var cancellableLoginEnv : AnyCancellable?


    var cancellableLoginSuccess: AnyCancellable?
    var service: (()->Void)? = nil
    
    // imposta navigation controller e router principale da presentare con il metodo start
    public init(navigationController: UINavigationController = .init(), startingRoute: MainRouter? = nil) {
        self.navigationController = navigationController
        self.startingRoute = startingRoute
        // Inserire qui il trigger per ascoltare i cambiamenti dentro gli environment
        // Trigger Db Environment
        cancellableDb = dbEnv.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        
        // Trigger Login Environment
        cancellableLoginEnv = loginEnv.objectWillChange.sink { [weak self] (_) in
            self?.objectWillChange.send()
        }
        
//
//        let notification = Notification.Name.Notifiche.dettaglio
//        NotificationCenter.default.addObserver(forName: notification,
//                                               object: nil,
//                                               queue: nil) { (notification) in
//            let idNotifica = notification.object as? String
//            self.showNotificationForAppDelegate(idNotifica: idNotifica ?? "")
//        }
        
        // Quando l'app è chiusa, effettuo questo controllo per capire se è arrivata una notifica
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        let idNotifica = appDelegate.idNotifica
//        if !idNotifica.isEmpty {
//            self.showNotificationForAppDelegate(idNotifica: idNotifica)
//            appDelegate.idNotifica = ""
//        }
        
//        let notificationSmartTVQrCode = Notification.Name.SmartTV.qrCode
//        NotificationCenter.default.addObserver(forName: notificationSmartTVQrCode,
//                                               object: nil,
//                                               queue: nil) { (notification) in
//            let code = notification.object as? String
//            self.show(self.servicesEnv.serviceSmartTV())
//        }
    }
    
    // vai alla view principare impostata nel costruttore
    public func start() {
        guard let route = startingRoute else { return }
        show(route)
    }
    
    public func show(_ route: MainRouter, animated: Bool = true) {
        
        self.service = nil
        
        // controllo se il router di destinazione è con autenticazione
//        let loginRequired = self.loginRequired(isAuthRequired: route.isAuthenticationRequired, {
//            self.show(route) // appena loggato richiama show
//        })
//        
        // se ha bisogno di autenticazione non va avanti
//        guard !loginRequired else {
//            return
//        }
        
        // aggiungo il router nello stack
        self.stackRouting.append(route)
        
        // prendo la view dal router
        let view = route.view()
        
        // passo il coordinatore come environment object e nascondo navigation
        let viewWithCoordinator = view.environmentObject(self)
            .environmentObject(dbEnv)
            .environmentObject(loginEnv)
            .navigationBarHidden(true)
        
        // imposto view controller
        let viewController = UIHostingController(rootView: viewWithCoordinator)
        
        // do un tag per associare il controller al router
        viewController.view.tag = self.stackRouting.count
        
        // presenta la view in base alla transizione impostata nel router
        switch route.transition {
        case .push:
            navigationController.pushViewController(viewController, animated: animated)
        case .presentModally:
            viewController.modalPresentationStyle = .formSheet
            navigationController.present(viewController, animated: animated)
        case .presentFullscreen:
            viewController.modalPresentationStyle = .fullScreen
            navigationController.present(viewController, animated: animated)
        }
        
        self.cancellableLoginSuccess = nil
        self.service = nil
    }
    
    public func pop(animated: Bool = true, navigationController: UINavigationController? = nil) {
        let nav = navigationController ?? self.navigationController
        if nav.popViewController(animated: animated) != nil {
            // elimina dallo stack il router
            self.stackRouting.removeLast()
        } else {
            self.dismiss(animated: animated, navigationController: navigationController)
        }
    }
    
    public func popToRoot(animated: Bool = true, navigationController: UINavigationController? = nil) {
        // resetto lo stack e lascio la vista principale
        if let firstRouter = self.stackRouting.first {
            self.stackRouting.removeAll()
            self.stackRouting.append(firstRouter)
        }
        
        let navigationController = navigationController ?? self.navigationController
        
        // prendo vista principale in base al tag associato
        if let controller = navigationController.viewControllers.first(where: { $0.view.tag == 1 }) {
            
            // faccio il pop verso la vista principale
            navigationController.popToViewController(controller, animated: true)
        }
    }
    
    
    // metodo per poter tornare ad una vista presentata in precedenza passando il router specifico per poter funzionare bisogna che viene assegnato il tag alla view dell'HostingViewController nel coordinator come viene fatto nel metodo show in questo modo: viewController.view.tag = mainCoordinator.stackRouting.count
    // main coordinator perche verra fatto nel coordinator specifico
    // creare anche nel nuovo coordinator il metodo che specializza il router di appartenenza ad esempio:
    // public func popToRouter(_ router: AURouter, animated: Bool = true) {
    //    mainCoordinator.popToRouter(router, animated: animated)
    // }
    // O usare quello del main se si vuole tornare ad una vista al di fuori specificando il NavigationRouter
    public func popToRouter<T:Equatable>(_ router: T, animated: Bool = true, navigationController: UINavigationController? = nil) {
        if let indexRouterStack = self.stackRouting.firstIndex(where: { ($0 as? T) == router }) {
            
            let tagRouterInStack = indexRouterStack + 1
            
            let navigationController = navigationController ?? self.navigationController
            
            // prendo vista principale in base al tag associato
            if let controller = navigationController.viewControllers.first(where: { $0.view.tag == tagRouterInStack }) {

                // resetto lo stack fino al router base
                let range = tagRouterInStack...self.stackRouting.count-1
                self.stackRouting.removeSubrange(range)

                // faccio il pop verso la vista base
                navigationController.popToViewController(controller, animated: true)
            }
        }
    }
    
    // metodo che rimuove dalla navigazione il router inserito
    public func removeRouter<T:Equatable>(_ router: T, animated: Bool = true, navigationController: UINavigationController? = nil) {
        
        // controllo se è presenta nello stack
        if let indexRouterStack = self.stackRouting.firstIndex(where: { ($0 as? T) == router }) {
            
            // prendo(id) il tag del router nello stack
            let tagRouterInStack = indexRouterStack + 1
            
            // puo essere passato un nuovo navigatio per tenere traccia dei router nella nuova navigazione
            // usato per navigazione modali
            let navigationController = navigationController ?? self.navigationController
            
            // prendo vista principale in base al tag associato
            if let indexStack = navigationController.viewControllers.firstIndex(where: { $0.view.tag == tagRouterInStack }) {

                // resetto lo stack fino al router base
                self.stackRouting.remove(at: tagRouterInStack)

                // cancello dallo stack del navigation il router selezionato
                navigationController.viewControllers.remove(at: indexStack)
            }
        }
    }
    
    open func dismiss(animated: Bool = true, navigationController: UINavigationController? = nil) {
        
        // puo essere passato un nuovo navigatio per tenere traccia dei router nella nuova navigazione
        // usato per navigazione modali
        let navigationController = navigationController ?? self.navigationController
        
        // esco dalla modale
        navigationController.dismiss(animated: animated) { }
        
        // prendo il tag(id) della navigazione modale(dove vengono registrate le navigazioni)
        if let firstIndex = navigationController.viewControllers.first?.view.tag {
            
            // prendo tag(id) del router nello stack
            let tagRouterInStack = firstIndex - 1
            
            // controllo se è minore del numero totale degli elementi della navigazione
            let stackRoutingCount = self.stackRouting.count
            if tagRouterInStack < stackRoutingCount {
                
                // prendo range di indici che fanno parte della navigazione da distruggere
                let range = tagRouterInStack...stackRoutingCount-1
                
                // cancello router di navigazione
                self.stackRouting.removeSubrange(range)
            } else {
                
                // cancello ultimo elemento
                self.stackRouting.removeLast()
            }
        }
    }
}

//extension Coordinator {
//    
//    //
//    // login
//    //
//    // metodo login centralizzata per effettuare la login richiamando da coordinator
//    // success: login effettuata
//    // service: vai al servizio
//    func login(success: (()-> Void)? = nil, service: (()-> Void)? = nil) {
//        guard let self = self as? Coordinator<Router> else { print("ATTENZIONE!!! ERRORE MAIN ROUTER NON DI TIPO ROUTER"); return }
//        let idRouter = self.stackRouting.count
//        let newCoordinator = LoginCoordinator.init(mainCoordinator: self, startingRoute: .user)
//        DispatchQueue.main.async {
//            newCoordinator.start()
//        }
//        
//        if self.service == nil {
//            self.service = service
//        }
//        self.cancellableLoginSuccess = self.loginEnv.$isLogged.sink { [weak self] isLogged in
//            if isLogged {
//                DispatchQueue.main.async {
//                    
//                    success?()
//                    
//                    guard let idLastRouter = self?.stackRouting.count else {
//                        print("ATTENZIONE!!! ERRORE STACKROUTER VUOTO");
//                        return
//                    }
//                    
//                    if idLastRouter == idRouter {
//                        self?.service?()
//                    }
//                }
//            }
//        }
//    }
//    
//    //
//    // login required
//    //
//    // metodo che restituisce se hai bisgno di autenticazione e tramite completion appena viene effettuata la login viene richiamato
//    // isAuthRequired: se necessita di autenticazione
//    // completion: clousure che viene richiamata al completamento della login
//    func loginRequired(isAuthRequired: Bool, _ completion: (()-> Void)? = nil) -> Bool {
//        guard !isAuthRequired || (isAuthRequired && loginEnv.isLogged) else {
//            self.login(service: completion)
//            return true
//        }
//        return false
//    }
//}

