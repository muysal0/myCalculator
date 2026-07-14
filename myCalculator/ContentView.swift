import SwiftUI

struct ContentView: View {
    @State private var ekranYazisi: String = "0"
    @State private var isDarkMode: Bool = true
    
    @State private var oncekiSayi: Double = 0
    @State private var aktifIslem: String? = nil
    @State private var yeniSayiGiriliyor: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isDarkMode.toggle()
                } label: {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.title)
                        .foregroundColor(isDarkMode ? .yellow : .indigo)
                        .padding()
                }
            }
            
            Spacer()
            
            Text(ekranYazisi)
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(isDarkMode ? .white : .black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            
            Grid(horizontalSpacing: 12, verticalSpacing: 12) {
                GridRow {
                    ozelButon("C", renk: .red)
                    ozelButon("+/-", renk: .gray)
                    ozelButon("%", renk: .gray)
                    ozelButon("÷", renk: .orange)
                }
                
                GridRow {
                    ozelButon("7")
                    ozelButon("8")
                    ozelButon("9")
                    ozelButon("×", renk: .orange)
                }
                
                GridRow {
                    ozelButon("4")
                    ozelButon("5")
                    ozelButon("6")
                    ozelButon("-", renk: .orange)
                }
                
                GridRow {
                    ozelButon("1")
                    ozelButon("2")
                    ozelButon("3")
                    ozelButon("+", renk: .orange)
                }
                
                GridRow {
                    ozelButon("0")
                        .gridCellColumns(2)
                    
                    ozelButon(".")
                    ozelButon("=", renk: .green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(isDarkMode ? Color.black : Color(UIColor.systemGray6))
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
    
    func ozelButon(_ baslik: String, renk: Color = .blue) -> some View {
        Button {
            butonaBasildi(deger: baslik)
        } label: {
            Text(baslik)
                .font(.title)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .frame(height: 75)
                .background(renk.gradient)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: renk.opacity(0.3), radius: 5, x: 0, y: 5)
        }
    }
    
    func butonaBasildi(deger: String) {
        switch deger {
        case "C":
            ekranYazisi = "0"
            oncekiSayi = 0
            aktifIslem = nil
            yeniSayiGiriliyor = false
            
        case "+/-":
            if ekranYazisi != "0" {
                if ekranYazisi.hasPrefix("-") {
                    ekranYazisi.removeFirst()
                } else {
                    ekranYazisi = "-" + ekranYazisi
                }
            }
            
        case "%":
            if let sayi = Double(ekranYazisi) {
                ekranYazisi = formatla(sayi / 100)
            }
            
        case "+", "-", "×", "÷":
            if let sayi = Double(ekranYazisi) {
                oncekiSayi = sayi
            }
            aktifIslem = deger
            yeniSayiGiriliyor = true
            
        case "=":
            hesapla()
            yeniSayiGiriliyor = true
            
        case ".":
            if yeniSayiGiriliyor {
                ekranYazisi = "0."
                yeniSayiGiriliyor = false
            } else if !ekranYazisi.contains(".") {
                ekranYazisi += "."
            }
            
        default:
            if yeniSayiGiriliyor {
                ekranYazisi = deger
                yeniSayiGiriliyor = false
            } else {
                if ekranYazisi == "0" {
                    ekranYazisi = deger
                } else {
                    ekranYazisi += deger
                }
            }
        }
    }
    
    func hesapla() {
        guard let islem = aktifIslem, let suankiSayi = Double(ekranYazisi) else { return }
        
        var sonuc: Double = 0
        
        switch islem {
        case "+": sonuc = oncekiSayi + suankiSayi
        case "-": sonuc = oncekiSayi - suankiSayi
        case "×": sonuc = oncekiSayi * suankiSayi
        case "÷": sonuc = suankiSayi == 0 ? 0 : oncekiSayi / suankiSayi
        default: break
        }
        
        ekranYazisi = formatla(sonuc)
        aktifIslem = nil
    }
    
    func formatla(_ sayi: Double) -> String {
        if sayi.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", sayi)
        }
        return String(sayi)
    }
}

#Preview {
    ContentView()
}
