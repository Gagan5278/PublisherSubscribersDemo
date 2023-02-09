//
//  Basics.swift
//  PublisherSubscriber
//
//  Created by Gagan Vishal  on 2023/02/09.
//

import SwiftUI
import Combine

class CombinedDataService {
    /* 1.
     @Published var basicPublisher: [String] = []
     */
    
    /* 2.
     @Published var basicPublisher: String = ""
     */
    
    var currentValueSubject = CurrentValueSubject<String, Error>("Initial value")
    
    var passthroughSubject = PassthroughSubject<String, Error>()
    
    var passthroughSubjectInt = PassthroughSubject<Int, Error>()
    
    
    init() {
        publishFakeData()
    }
    
    private func publishFakeData() {
        /* 1.
         DispatchQueue.main.async { [weak self] in
         self?.basicPublisher = ["One", "Two", "Three"]
         }
         */
        
        /* 2.
         let items = ["one", "two", "three"]
         for index in items.indices {
         DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) { [weak self] in
         self?.basicPublisher = items[index]
         }
         }
         */
        
        /* 3. & 4.
         let items = ["one", "two", "three"]
         for index in items.indices {
         DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) { [weak self] in
         // self?.currentValueSubject.send(items[index])
         
         self?.passthroughSubject.send(items[index])
         }
         }
         */
        
        let items = Array(0..<11)
        for index in items.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)) { [weak self] in
                self?.passthroughSubjectInt.send(items[index])
                if index == items.count - 1 {
                    self?.passthroughSubjectInt.send(completion: .finished)
                }
            }
        }
    }
}

class CombinedDataViewModel: ObservableObject {
    @Published var data: [String] = []
    @Published var errorString: String = ""
    private var cancellables = Set<AnyCancellable>()
    let dataService = CombinedDataService()
    
    init() {
        addSubscriber()
    }
    
    private func addSubscriber() {
        /* 1 & 2
         dataService.$basicPublisher
         .sink { completion in
         switch completion {
         case .finished: break
         case .failure(let error):
         print(error.localizedDescription)
         }
         } receiveValue: {[weak self] value in
         /* 1.
          self?.data = values
          */
         self?.data.append(value)
         }
         .store(in: &cancellables)
         */
        
        
        /* 3 & 4
         // dataService.currentValueSubject
         dataService.passthroughSubject
         .sink { completion in
         switch completion {
         case .finished: break
         case .failure(let error):
         print(error.localizedDescription)
         }
         } receiveValue: { [weak self] value in
         self?.data.append(value)
         }
         .store(in: &cancellables)
         */
        
        
        // MARK: - On int opertaions
        dataService.passthroughSubjectInt
        //SEQUENCE OPERATIONS
        /*
//             .first()
//            .first(where: ({$0 > 4}))

        
//         .tryFirst(where: { int in
//             if int == 5 {
//                 throw URLError(.badServerResponse)
//             }
//             return int > 0
//         })
        
//            .last()
//            .last(where: {$0 > 5})
//            .dropFirst()
//            .dropFirst(3)
//            .drop(while: {$0 < 4}) // return when false
//            .tryDrop(while: { int in
//                if int == 3 {
//                    throw URLError(.badServerResponse)
//                }
//                return int < 4
//            }) // check for false state
//            .prefix(3)
//            .prefix(while: {$0 < 4})
//            .output(at: 4)
//            .output(in: 2...4)
         */
        
        //MATH OPERATIONS
        /*
         //            .max()
         //            .max(by: { first, second in
         //                return first > second
         //            })
         //            .min()
         //            .min(by: { first, second in
         //                return first < second
         //            })
         */

            .map({String($0)})
            .sink { [weak self]  completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.errorString =  error.localizedDescription
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] value in
                self?.data.append(value)
            }
            .store(in: &cancellables)
    }
}



struct Basics: View {
    @StateObject var viewModel = CombinedDataViewModel()
    var body: some View {
        VStack {
            ForEach(viewModel.data, id:\.self) { item in
                Text(item)
                    .font(.title)
                    .fontWeight(.medium)
            }
            if !viewModel.errorString.isEmpty {
                Text(viewModel.errorString)
                    .font(.title3)
                    .foregroundColor(.red)
            }
            Spacer()
        }
    }
}

struct Basics_Previews: PreviewProvider {
    static var previews: some View {
        Basics()
    }
}
