//
//  HomeScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS
import Charts

struct HomeScreen: View {
    
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .bars, action: {
            
        })
    }
    
    private var profile: AppNavigationItemData {
        return AppNavigationItemData(icon: .user, action: {
            
        })
    }
    
    @State var progress1: Double = 0.0
    @State var progress2: Double = 0.0
    @State var progress3: Double = 0.0
    
    var body: some View {
        AppNavigationView {
            VStack(alignment: .leading) {
                SirioText(text: "My Files", typography: .label_md_600)
                
                FileDistributionBarView(documentPercentage: 0.43, photoPercentage: 0.35, videoPercentage: 0.22)
                
                ZStack {
                    Circle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    Circle()
                        .trim(from: 0.0, to: progress1)
                        .stroke(Color.colorDocuments, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90)) // Per far iniziare il progresso da 0 gradi
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    
                    
                    Circle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0.0, to: progress2)
                        .stroke(Color.colorPhotos, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90)) // Per far iniziare il progresso da 0 gradi
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0.0, to: progress3)
                        .stroke(Color.colorMedia, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90)) // Per far iniziare il progresso da 0 gradi
                        .frame(width: 60, height: 60)
                }
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.0) // Modifica la durata desiderata (in secondi)
                    ) {
                        self.progress1 = 0.43
                        self.progress2 = 0.35
                        self.progress3 = 0.22
                    }
                }
                
                .padding(20)
                
                //SectorChartExample()
                InteractiveDonutView()
                //DonutChart()
                HStack {
                    Circle()
                        .fill(Color.colorDocuments)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: "Documents", typography: .label_md_400)
                    
                    Circle()
                        .fill(Color.colorPhotos)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: "Photos", typography: .label_md_400)
                    
                    Circle()
                        .fill(Color.colorMedia)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: "Media", typography: .label_md_400)
                    
                    //Spacer()
                }
            }
            .padding()
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
        }
    }
}

#Preview {
    HomeScreen()
}

//struct Product: Identifiable, Equatable {
//    let id = UUID()
//    let title: String
//    let percent: Double
//    let color: Color
//}


struct SectorChartExample: View {
    @State private var products: [Product] = [
        .init(category: "Documents", percent: 0.20, color: Color.colorDocuments),
        .init(category: "Photos", percent: 0.30, color: Color.colorPhotos),
        .init(category: "Media", percent: 0.18, color: Color.colorMedia),
        .init(category: "Free", percent: 0.32, color: Color.gray.opacity(0.8))
    ]
    //    @State private var selectedProduct: Product? = nil
    
    var selectedProduct: Product? {
        return products.filter({ $0.percent == selectedpercent }).first
    }
    
    @State private var selectedpercent: Double? = nil
    
    var body: some View {
        Chart(products) { product in
            SectorMark(
                angle: .value(
                    Text(verbatim: product.category),
                    product.percent
                ),
                innerRadius: .ratio(selectedProduct == product ? 0.5 : 0.6),
                outerRadius: .ratio(selectedProduct == product ? 1.0 : 0.9),
                angularInset: 3.0
            )
            .cornerRadius(6.0)
            .foregroundStyle(product.color)
            
        }
        .chartAngleSelection(value: $selectedpercent)
        // Display data for selected sector
        .chartBackground { chartProxy in
            GeometryReader { geometry in
                let frame = geometry[chartProxy.plotFrame!]
                if let selectedProduct = selectedProduct {
                    VStack(spacing: 0) {
                        Text(selectedProduct.category )
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(width: 120, height: 80)
                        Text("€\(selectedProduct.percent , specifier: "%.1f") M")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
                
            }
        }
        .frame(width: 180, height: 180)
        .animation(.snappy)
    }
}

//MARK:- Chart Data
struct ChartData {
    var id = UUID()
    var color : Color
    var percent : CGFloat
    var value : CGFloat
    
}

class ChartDataContainer : ObservableObject {
    @Published var chartData =
    [ChartData(color: Color(#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1)), percent: 8, value: 0),
     ChartData(color: Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)), percent: 15, value: 0),
     ChartData(color: Color(#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)), percent: 32, value: 0),
     ChartData(color: Color(#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1)), percent: 45, value: 0)]
    
    //    init() {
    //        calc()
    //    }
    func calc(){
        var value : CGFloat = 0
        
        for i in 0..<chartData.count {
            value += chartData[i].percent
            chartData[i].value = value
        }
    }
}

struct PieChart : View {
    @ObservedObject var charDataObj = ChartDataContainer()
    @State var indexOfTappedSlice = -1
    var body: some View {
        VStack {
            //MARK:- Pie Slices
            ZStack {
                ForEach(0..<charDataObj.chartData.count) { index in
                    Circle()
                        .trim(from: index == 0 ? 0.0 : charDataObj.chartData[index-1].value/100,
                              to: charDataObj.chartData[index].value/100)
                        .stroke(charDataObj.chartData[index].color,lineWidth: 100)
                        .scaleEffect(index == indexOfTappedSlice ? 1.1 : 1.0)
                        .animation(.spring())
                }
            }.frame(width: 200, height: 200)
                .onAppear() {
                    self.charDataObj.calc()
                }
            
            ForEach(0..<charDataObj.chartData.count) { index in
                HStack {
                    Text(String(format: "%.2f", Double(charDataObj.chartData[index].percent))+"%")
                        .onTapGesture {
                            indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
                        }
                        .font(indexOfTappedSlice == index ? .headline : .subheadline)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(charDataObj.chartData[index].color)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(8)
            .frame(width: 300, alignment: .trailing)
        }
    }
}

struct DonutChart : View {
    @ObservedObject var charDataObj = ChartDataContainer()
    @State var indexOfTappedSlice = -1
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<charDataObj.chartData.count) { index in
                    Circle()
                        .trim(from: index == 0 ? 0.0 : charDataObj.chartData[index-1].value/100,
                              to: charDataObj.chartData[index].value/100)
                        .stroke(charDataObj.chartData[index].color,lineWidth: 50)
                        .onTapGesture {
                            indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
                        }
                        .scaleEffect(index == indexOfTappedSlice ? 1.1 : 1.0)
                        .animation(.spring())
                }
                if indexOfTappedSlice != -1 {
                    Text(String(format: "%.2f", Double(charDataObj.chartData[indexOfTappedSlice].percent))+"%")
                        .font(.title)
                }
            }
            .frame(width: 200, height: 200)
            .padding()
            .onAppear() {
                self.charDataObj.calc()
            }
            
            ForEach(0..<charDataObj.chartData.count) { index in
                HStack {
                    Text(String(format: "%.2f", Double(charDataObj.chartData[index].percent))+"%")
                        .onTapGesture {
                            indexOfTappedSlice = indexOfTappedSlice == index ? -1 : index
                        }
                        .font(indexOfTappedSlice == index ? .headline : .subheadline)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(charDataObj.chartData[index].color)
                        .frame(width: 15, height: 15)
                }
            }
            .padding(8)
            .frame(width: 300, alignment: .trailing)
        }
    }
}

struct Product: Identifiable, Equatable {
    var category: String
    var percent: Double
    var color: Color
    var id = UUID()
}


struct InteractiveDonutView: View {
    @State private var selectedAmount: Double? = nil
    let cumulativeIncomes: [(category: String, range: Range<Double>)]

    init() {
        var cumulative = 0.0
        self.cumulativeIncomes = donationsIncomeData.map {
            let newCumulative = cumulative + Double($0.percent)
            let result = (category: $0.category, range: cumulative ..< newCumulative)
            cumulative = newCumulative
            return result
        }
    }
    let donationsIncomeData: [Product] = [
        .init(category: "Documents", percent: 0.20, color: Color.colorDocuments),
        .init(category: "Photos", percent: 0.30, color: Color.colorPhotos),
        .init(category: "Media", percent: 0.18, color: Color.colorMedia),
        .init(category: "Free", percent: 0.32, color: Color.gray.opacity(0.8))
//        .init(category: "Legacies", percent: 2.4),
//        .init(category: "Other national campaigns and donations", percent: 5.5),
//        .init(category: "Daffodil Day", percent: 4.7),
//        .init(category: "Philanthropy and corporate partnerships", percent: 4.0)
    ]
    var selectedCategory: Product? {
        if let selectedAmount,
           let selectedIndex = cumulativeIncomes
            .firstIndex(where: { $0.range.contains(selectedAmount) }) {
            return donationsIncomeData[selectedIndex]
        }
        return nil
    }
    
    var body: some View {
        VStack {
            GroupBox ( "2022 Donations and Legacies (€ million)") {
                Chart(donationsIncomeData) {
                    SectorMark(
                        angle: .value("Amount", $0.percent),
                        innerRadius: .ratio(selectedCategory == $0 ? 0.5 : 0.6),
                        outerRadius: .ratio(selectedCategory == $0 ? 1.0 : 0.9),
                        angularInset: 3.0
                    )
                    .cornerRadius(6.0)
                    .foregroundStyle(by: .value("category", $0.category))
                    .opacity(selectedCategory == $0 ? 1.0 : 0.9)
                }
                // Set color for each data in the chart
                .chartForegroundStyleScale(
                    domain: donationsIncomeData.map  { $0.category },
                    range: [Color.red, Color.yellow, Color.green]
                )
                
                // Position the Legend
                .chartLegend(position: .bottom, alignment: .center)
                
                // Select a sector
                .chartAngleSelection(value: $selectedAmount)
                
                // Display data for selected sector
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        VStack(spacing: 0) {
                            Text(selectedCategory?.category ?? "")
                                .multilineTextAlignment(.center)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .frame(width: 120, height: 80)
                            Text("€\(selectedCategory?.percent ?? 0, specifier: "%.1f") M")
                                .font(.title.bold())
                                .foregroundColor((selectedCategory != nil) ? .primary : .clear)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
                
            }
            .frame(height: 500)
            
//            // Testing chartAngleSelection
//            Text("SelectedAmount")
//            Text(selectedAmount?.formatted() ?? "none")

            Spacer()
        }
        .padding()
    }
}
