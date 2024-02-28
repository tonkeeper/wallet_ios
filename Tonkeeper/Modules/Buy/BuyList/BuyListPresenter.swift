//
//  BuyListBuyListPresenter.swift
//  Tonkeeper

//  Tonkeeper
//  Created by Grigory Serebryanyy on 09/06/2023.
//

import Foundation
import WalletCoreKeeper
import FirebaseRemoteConfig

final class BuyListPresenter {
  
  // MARK: - Module
  
  weak var viewInput: BuyListViewInput?
  weak var output: BuyListModuleOutput?
  
  // MARK: - Dependencies
  
  private let fiatMethodsController: FiatMethodsController
  private let buyListServiceBuilder: BuyListServiceBuilder
  private let appSettings = AppSettings()
  
  init(fiatMethodsController: FiatMethodsController,
       buyListServiceBuilder: BuyListServiceBuilder) {
    self.fiatMethodsController = fiatMethodsController
    self.buyListServiceBuilder = buyListServiceBuilder
  }
}

// MARK: - BuyListPresenterIntput

extension BuyListPresenter: BuyListPresenterInput {
  func viewDidLoad() {
    updateFiatMethods()
  }
  
  func didSelectServiceAt(indexPath: IndexPath) {
    Task {
      guard let item = await fiatMethodsController.fiatMethodViewModel(at: indexPath.section, item: indexPath.row) else {
        return
      }
      if appSettings.isFiatMethodPopUpMarkedDoNotShow(for: item.id) {
        guard let url = await fiatMethodsController.urlForMethod(item) else { return }
        await MainActor.run {
          output?.buyListModule(self, showWebView: url)
        }
      } else {
        await MainActor.run {
          output?.buyListModule(self, showFiatMethodPopUp: item)
        }
      }
    }
  }
}

// MARK: - BuyListModuleInput

extension BuyListPresenter: BuyListModuleInput {}

// MARK: - Private

private extension BuyListPresenter {
  func updateFiatMethods() {
    Task {
      do {
        let cachedViewModels = try await fiatMethodsController.getFiatMethods()
        await MainActor.run {
          viewInput?.updateSections(cachedViewModels.map {
            let cellModels = $0.map { buyListServiceBuilder.buildServiceModel(viewModel: $0) }
            return BuyListSection(type: .services, items: cellModels)
          })
        }
      } catch {}
      do {
        let loadedViewModels = try await fiatMethodsController.loadFiatMethods(isMarketRegionPickerAvailable: FirebaseConfigurator.configurator.isMarketRegionPickerAvailable)
        await MainActor.run {
          if loadedViewModels.isEmpty {
            viewInput?.showEmpty()
          } else {
            viewInput?.updateSections(loadedViewModels.map {
              let cellModels = $0.map { buyListServiceBuilder.buildServiceModel(viewModel: $0) }
              return BuyListSection(type: .services, items: cellModels)
            })
          }
        }
      } catch {
        await MainActor.run {
          viewInput?.showEmpty()
        }
      }
    }
  }
}
