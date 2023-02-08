//
//  SecondViewController.swift
//  PublisherSubscriber
//
//  Created by Gagan Vishal  on 2023/02/09.
//

import UIKit
import Combine

class SecondViewController: UIViewController {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    private let vm = QuoteViewModel()
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
      super.viewDidLoad()
      bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      input.send(.viewDidAppear)
    }
    
    private func bind() {
      let output = vm.transform(input: input.eraseToAnyPublisher())
        
      output
        .receive(on: DispatchQueue.main)
        .sink { [weak self] event in
        switch event {
        case .fetchQuoteDidSucceed(let quote):
          self?.quoteLabel.text = quote.content
        case .fetchQuoteDidFail(let error):
          self?.quoteLabel.text = error.localizedDescription
        case .toggleButton(let isEnabled):
          self?.refreshButton.isEnabled = isEnabled
        }
      }.store(in: &cancellables)
      
    }

    @IBAction func refreshButtonTapped(_ sender: Any) {
      input.send(.refreshButtonDidTap)
    }
  }
