//
//  AdFullScreenLoadingVC.swift
//  MobileAds
//
//  Created by macbook on 28/08/2021.
//

import UIKit

class AdFullScreenLoadingVC: UIViewController {

    @IBOutlet weak var lbLoading: UILabel!
    
    var timer: Timer?
    var timeOut: Int = 30
    var timeCount = 0
    var adUnitId: AdUnitID?
    var adType: AdMobFullScreenType?
    var blockWillDismiss: VoidBlockAds?
    var blockDidDismiss: VoidBlockAds?
    var blocWillPresent: VoidBlockAds?

    var needLoadAd = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if needLoadAd {
            loadAd()
        } else {
            showLoadingDotAds(backgroundColor: .white, textLoading: AdMobManager.shared.adFullScreenLoadingString)
        }
    }
    
    func loadAd() {
        guard let adUnitId = self.adUnitId, let adType = self.adType else {
            return
        }
        timeCount = 0
       
        adType.createAd()
       
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(1), target: self, selector: #selector(self.checkTimmer), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
        
        if adType.isExisted {
            self.stopCheckTimmer()
            self.showLoadingDotAds(backgroundColor: .white, textLoading: AdMobManager.shared.adFullScreenLoadingString)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                adType.presentAd()
            }
            
            AdMobManager.shared.blockFullScreenAdDidDismiss = { [weak self] in
                AdMobManager.shared.removeAd(unitId: adUnitId.rawValue)
                adType.createAd()
                guard let _self = self else {
                    return
                }
                _self.stopCheckTimmer()
                _self.blockDidDismiss?()
            }
            
            AdMobManager.shared.blockFullScreenAdWillPresent =  { [weak self] unitId in
                guard let _self = self, _self.adUnitId?.rawValue == unitId else {
                    return
                }
                _self.blocWillPresent?()
            }
            
            AdMobManager.shared.blockFullScreenAdWillDismiss =  { [weak self]  in
                guard let _self = self else {
                    return
                }
                _self.hideLoading()
                _self.blockWillDismiss?()
            }
            
            AdMobManager.shared.blockFullScreenAdFaild =  { [weak self] unitId in
                guard let _self = self, _self.adUnitId?.rawValue == unitId else {
                    return
                }
                _self.stopCheckTimmer()
                _self.blockDidDismiss?()
            }

        } else {
            showLoadingDotAds(backgroundColor: .white, textLoading: AdMobManager.shared.adFullScreenLoadingString)
            AdMobManager.shared.blockLoadFullScreenAdSuccess = { [weak self] unitId in
                guard let _self = self, _self.adUnitId?.rawValue == unitId else {
                    return
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
                    adType.presentAd()
                }

                _self.stopCheckTimmer()
             
            }
            
            AdMobManager.shared.blockFullScreenAdWillDismiss =  { [weak self] in
                guard let _self = self else {
                    return
                }
                _self.stopCheckTimmer()
                _self.hideLoading()
                _self.blockWillDismiss?()
            }
            
            AdMobManager.shared.blockFullScreenAdDidDismiss = { [weak self] in
                AdMobManager.shared.removeAd(unitId: adUnitId.rawValue)
                adType.createAd()
                guard let _self = self else {
                    return
                }
                _self.stopCheckTimmer()
                _self.blockDidDismiss?()
            }
            
            AdMobManager.shared.blockFullScreenAdWillPresent =  { [weak self] unitId in
                guard let _self = self, _self.adUnitId?.rawValue == unitId else {
                    return
                }
                _self.blocWillPresent?()
            }
            
            AdMobManager.shared.blockFullScreenAdFaild =  { [weak self] unitId in
                guard let _self = self, _self.adUnitId?.rawValue == unitId else {
                    return
                }
                _self.stopCheckTimmer()
                _self.blockDidDismiss?()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.hideLoading()
            self?.stopCheckTimmer()
        }
    }
    
    private func hideLoading() {
        self.hideLoadingDotAds()
    }
    
    private func stopCheckTimmer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @objc func checkTimmer() {
        self.timeCount += 1
        if self.timeCount == 30 {
            // time out
            self.stopCheckTimmer()
            self.blockDidDismiss?()
        }
        print("\( self.timeCount)")
    }
    
    static func createViewController(unitId: AdUnitID, adType: AdMobFullScreenType) -> AdFullScreenLoadingVC {
        let vc = AdFullScreenLoadingVC(nibName: "AdFullScreenLoadingVC", bundle: nil)
        vc.modalPresentationStyle = .fullScreen
        vc.adUnitId = unitId
        vc.adType = adType
        return vc
    }

}
