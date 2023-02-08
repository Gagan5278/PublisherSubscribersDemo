//
//  QuoteService.swift
//  PublisherSubscriber
//
//  Created by Gagan Vishal  on 2023/02/09.
//

import Foundation
import Combine

protocol QuoteServiceType {
  func getRandomQuote() -> AnyPublisher<Quote, Error>
}

class QuoteService: QuoteServiceType {
  
  func getRandomQuote() -> AnyPublisher<Quote, Error> {
    let url = URL(string: "https://api.quotable.io/random")!
    return URLSession.shared.dataTaskPublisher(for: url)
      .catch { error in
        return Fail(error: error).eraseToAnyPublisher()
      }.map({ $0.data })
      .decode(type: Quote.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}
