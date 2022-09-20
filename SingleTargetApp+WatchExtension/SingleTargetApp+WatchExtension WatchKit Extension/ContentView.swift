//
//  ContentView.swift
//  SingleTargetApp+WatchExtension WatchKit Extension
//
//  Created by Akira Hayakawa on 2022/09/21.
//

import SwiftUI
import HealthKit

let readTypes: Set<HKQuantityType> = [
    HKObjectType.quantityType(forIdentifier: .heartRate)!,
    HKObjectType.quantityType(forIdentifier: .stepCount)!
]

struct ContentView: View {
    @State var value: String = ""
    var body: some View {
        Text("Hello, World! \(value)")
            .padding()
            .onAppear {
                Task {@MainActor in
                    let store = HKHealthStore()
                    try await store.requestAuthorization(toShare: [], read: readTypes)
                    
                    let stepType = HKQuantityType(.stepCount)

                    // Create the descriptor.
                    let descriptor = HKSampleQueryDescriptor(
                        predicates:[.quantitySample(type: stepType)],
                        sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
                        limit: 10)

                    // Launch the query and wait for the results.
                    // The system automatically sets results to [HKQuantitySample].
                    let results = try await descriptor.result(for: store)
                    
                    let totalSteps = results.reduce(0, {$0+$1.quantity.doubleValue(for: .count())})
                    
                    self.value = String(totalSteps)
                }
            }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
