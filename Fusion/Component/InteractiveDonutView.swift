//
//  InteractiveDonutView.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import Charts

struct InteractiveDonutView: View {
    @State private var selectedAmount: Double? = nil
    @State private var cumulativeIncomes: [(category: String, range: Range<Double>)] = []
    @Binding var products: [Product]
    
    var selectedCategory: Product? {
        if let selectedAmount,
           let selectedIndex = cumulativeIncomes
            .firstIndex(where: { $0.range.contains(selectedAmount) }) {
            return products[selectedIndex]
        }
        return nil
    }
    
    init(products: Binding<[Product]>) {
        self._products = products
        self.setData()
    }
    
    func setData(){
        withAnimation {
            var cumulative = 0.0
            self.cumulativeIncomes = products.map {
                let newCumulative = cumulative + Double($0.percent)
                let result = (category: $0.category.rawValue, range: cumulative ..< newCumulative)
                cumulative = newCumulative
                return result
            }
        }
    }
    
    var body: some View {
        VStack {
            Chart(products) { product in
                SectorMark(
                    angle: .value("Percent", product.percent),
                    innerRadius: .ratio(selectedCategory == product ? 0.5 : 0.6),
                    outerRadius: .ratio(selectedCategory == product ? 1.0 : 0.9),
                    angularInset: 1.5
                )
                .foregroundStyle(product.primaryColor)
                .cornerRadius(6.0)
                .foregroundStyle(by: .value("Category", product.category.rawValue))
                .opacity(selectedCategory == product ? 1.0 : 0.9)
                
            }
            // Set color for each data in the chart
            .chartForegroundStyleScale(
                domain: products.map  { $0.category.rawValue },
                range: products.map { $0.primaryColor }
            )
            
            // Position the Legend
            .chartLegend(.hidden)
            //.chartLegend(position: .trailing, alignment: .center)
            // Select a sector
            .chartAngleSelection(value: $selectedAmount)
            .animation(.bouncy, value: $selectedAmount.wrappedValue)
            // Display data for selected sector
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    let frame = geometry[chartProxy.plotFrame!]
                    if let category = selectedCategory?.category, let percent = selectedCategory?.percent {
                        VStack(spacing: 0) {
                            MGText(text: category.rawValue, textColor: .secondary, fontType: .regular, fontSize: 12)
                                .multilineTextAlignment(.center)
                            MGText(text: "\(percent.toFormattedString())%", textColor: .secondary, fontType: .regular, fontSize: 12)
                                .multilineTextAlignment(.center)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
        }
        .onChange(of: products, {
            DispatchQueue.main.async {
                setData()
            }
        })
        
        // Considerare di richiamare il setData soltanto quando cambia per davvero
//        // Esempio di utilizzo di onChange con identificatore univoco
//               .onChange(of: products, perform: { newProducts in
//                   // Esegui l'aggiornamento solo se l'identificatore univoco cambia
//                   if products.count != newProducts.count {
//                       products = newProducts
//                   }
//               })
    }
}
//
//
//#Preview {
//    InteractiveDonutView(products: Product.preview)
//}
