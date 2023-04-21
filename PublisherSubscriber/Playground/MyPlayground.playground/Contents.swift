import UIKit
import Combine

private var cancellables = Set<AnyCancellable>()


// MARK: - JUST
/*
 * A Publisher that emits an output to each subscriber just once, and then finishes.
 */


let justPublisher = Just("Just-Demo")

justPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output in
    print(output)
}

// MARK: - FUTURE
/*
 * A publisher that emits a single value at some point in Future and then finishes.
 */

let futurePublisher = Future<String, Never> { promise in
    let someFutureVal = "Some Future value recieved"
    sleep(5) // Sleep for 5 seconds
    promise(.success(someFutureVal))
}

futurePublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output in
    print(output)
}


// MARK: - DEFERRED
/*
 * A publisher that wait for subscriber before running the provided clusure to create value for subscriber. In short, A DEFERRED publisher is useful when we want to delay the cretaion of publisher untile a subscriber is ready to recieve its value.
 */

let defferedPublisher = Deferred {
    Future<String, Never> { promise in
        let defferedString = "Some deffered string"
        promise(.success(defferedString))
    }
}

 defferedPublisher.sink { completion in
     switch completion {
     case .finished: break
     case .failure(let error): print(error)
     }
 } receiveValue: { output in
    print(output)
 }


// MARK: - EMPTY
/*
 * A publisher that immediately finishes without emmiting any error or Value.
 */

let emptyPublisher = Empty<String, Never>()

emptyPublisher.sink { completion in
    switch completion {
    case .finished: print("Completed completion")
    case .failure(let error): print(error)
    }
} receiveValue: { output in
    print(output)
    print("********Completed Empty does not print here********")
 }


// MARK: - SEQUENCE
/*
 * A publisher that emits sequence of values one at a time. Its useful when we have collection of values that we want to emit one at a time.
 */

let sequencePublisher = ["First", "2", "Third", "4"].publisher

sequencePublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output in
    print(output)
 }


// MARK: - FAIL
/*
 * A publisher that immediatley emits an error and finishes.
 */

let failPublisher = Fail<String, Error>(error: NSError(domain: "some_domain", code: -1))

failPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output in
    print(output)
 }


// MARK: - RECORD
/*
 * A publisher that record a series of inputs and compltion for later playback to each subscriber. We can create a Record publisher by using Record type which accepts an array of values and a completion event in its parameter.
 */

let items = ["Item11", "Item12", "Item22", "Item32", "Item42"]
let recordPublisher = Record<String, Error>(output: items, completion: .finished /*.failure(NSError(domain: "some_domain", code: -1) as! Error)*/)

recordPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output1 in
    print(output1)
 }

recordPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output2 in
    print(output2)
 }

// Record publisher can also take completion closure, whcih can be used to record values
let recordCompletionPublisher = Record<String, Never> { items in
    items.receive("First item")
    items.receive("Second item")
    items.receive("Third item")
    items.receive("Fourth item")
    items.receive(completion: .finished)
}

recordCompletionPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output1 in
    print(output1)
 }

recordCompletionPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { output2 in
    print(output2)
 }


// MARK: - SHARE
/*
 * A publisher that share single subsription to its upstream publisher with multiple downstream subscriber. Share does not create a new subscription to upstream publisher instead it share the existing subsxcription to all its subsriber.
 */

let imageURL = URL(string: "https://picsum.photos/200/300")!

// It creates two subscription to the dataTaskPublisher which can be redundant and inefficient.
 let dataPublisher = URLSession.shared.dataTaskPublisher(for: imageURL)

//let dataPublisher = URLSession.shared.dataTaskPublisher(for: imageURL).share()


dataPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { data, response in
    let image = UIImage(data: data)
}
.store(in: &cancellables)

dataPublisher.sink { completion in
    switch completion {
    case .finished: break
    case .failure(let error): print(error)
    }
} receiveValue: { data, response in
    let image = UIImage(data: data)
}
.store(in: &cancellables)
