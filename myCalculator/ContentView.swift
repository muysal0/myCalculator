import SwiftUI

struct ContentView: View {
    @State private var ekranYazisi: String = "0"
    @State private var devredenUzunluk: Int = 0
    @State private var isDarkMode: Bool = true
    @State private var oncekiSayi: Double = 0
    @State private var aktifIslem: String? = nil
    @State private var yeniSayiGiriliyor: Bool = false
    @State private var gecmisIslem: String = ""
    @State private var tumGecmis: [String] = []
    @State private var gecmisEkraniAcik: Bool = false
    
    var normalKisim: String {
        if devredenUzunluk > 0 && devredenUzunluk <= ekranYazisi.count {
            return String(ekranYazisi.dropLast(devredenUzunluk))
        }
        return ekranYazisi
    }
    
    var devredenKisim: String {
        if devredenUzunluk > 0 && devredenUzunluk <= ekranYazisi.count {
            return String(ekranYazisi.suffix(devredenUzunluk))
        }
        return ""
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    gecmisEkraniAcik = true
                } label: {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.title)
                        .foregroundColor(isDarkMode ? .white : .black)
                        .padding()
                }
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

            Text(gecmisIslem)
                .font(.system(size: 30, weight: .regular, design: .rounded))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, 24)
                .padding(.bottom, 5)
            
            HStack(spacing: 0) {
                Text(normalKisim)
                
                if devredenUzunluk > 0 {
                    Text(devredenKisim)
                        .overlay(
                            GeometryReader { geo in
                                Rectangle()
                                    .fill(isDarkMode ? Color.white : Color.black)
                                    .frame(height: max(geo.size.height * 0.05, 3))
                                    .offset(y: geo.size.height * 0.08)
                            },
                            alignment: .top
                        )
                }
            }
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
                    ozelButon("0").gridCellColumns(2)
                    ozelButon(".")
                    ozelButon("=", renk: .green)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .background(isDarkMode ? Color.black : Color(UIColor.systemGray6))
        .preferredColorScheme(isDarkMode ? .dark : .light)
        
        .onAppear {
            if let kaydedilenGecmis = UserDefaults.standard.stringArray(forKey: "HesapGecmisi") {
                tumGecmis = kaydedilenGecmis
            }
        }
        
        .sheet(isPresented: $gecmisEkraniAcik) {
            NavigationView {
                List {
                    ForEach(tumGecmis, id: \.self) { islem in
                        Text(islem)
                            .font(.title3)
                            .padding(.vertical, 5)
                    }
                }
                .navigationTitle("Geçmiş İşlemler")
                .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Kapat") {
                                    gecmisEkraniAcik = false
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Temizle") {
                                    tumGecmis.removeAll()
                                    UserDefaults.standard.removeObject(forKey: "HesapGecmisi")
                                }
                                .foregroundColor(.red)
                            }
                        }
            }
        }
        
        
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
            gecmisIslem = ""
            devredenUzunluk = 0
            
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
                devredenUzunluk = 0
            }
            
        case "+", "-", "×", "÷":
            if let sayi = Double(ekranYazisi) {
                oncekiSayi = sayi
            }
            aktifIslem = deger
            gecmisIslem = "\(formatla(oncekiSayi)) \(deger)"
            yeniSayiGiriliyor = true
            
        case "=":
            hesapla()
            yeniSayiGiriliyor = true
            
        case ".":
            if yeniSayiGiriliyor {
                ekranYazisi = "0."
                yeniSayiGiriliyor = false
                devredenUzunluk = 0
            } else if !ekranYazisi.contains(".") {
                ekranYazisi += "."
                devredenUzunluk = 0
            }
            
        default:
            if yeniSayiGiriliyor {
                ekranYazisi = deger
                yeniSayiGiriliyor = false
                devredenUzunluk = 0
            } else {
                if ekranYazisi == "0" {
                    ekranYazisi = deger
                } else {
                    ekranYazisi += deger
                }
                devredenUzunluk = 0
            }
        }
    }
    
    func hesapla() {
        guard let islem = aktifIslem, let suankiSayi = Double(ekranYazisi) else { return }
        
        gecmisIslem = "\(formatla(oncekiSayi)) \(islem) \(formatla(suankiSayi)) ="
        
        if islem == "÷" {
            devirliBolme(pay: oncekiSayi, payda: suankiSayi)
        } else {
            var sonuc: Double = 0
            switch islem {
            case "+": sonuc = oncekiSayi + suankiSayi
            case "-": sonuc = oncekiSayi - suankiSayi
            case "×": sonuc = oncekiSayi * suankiSayi
            default: break
            }
            ekranYazisi = formatla(sonuc)
            devredenUzunluk = 0
        }
        
        aktifIslem = nil
        let sonucYazisi = ekranYazisi
        let tamIslem = "\(gecmisIslem) \(sonucYazisi)"
        tumGecmis.insert(tamIslem, at: 0)

        UserDefaults.standard.set(tumGecmis, forKey: "HesapGecmisi")
    }
    
    func devirliBolme(pay: Double, payda: Double) {
        if payda == 0 {
            ekranYazisi = "Hata"
            devredenUzunluk = 0
            return
        }
        
        let carpan: Double = 100000
        var n = Int(round(pay * carpan))
        var d = Int(round(payda * carpan))
        
        let isNegative = (n < 0) != (d < 0)
        n = abs(n)
        d = abs(d)
        
        let tamKisim = n / d
        var kalan = n % d
        
        if kalan == 0 {
            ekranYazisi = (isNegative ? "-" : "") + "\(tamKisim)"
            devredenUzunluk = 0
            return
        }
        
        let sonuc = (isNegative ? "-" : "") + "\(tamKisim)."
        var kalanlar: [Int: Int] = [:]
        var ondalikKisim = ""
        
        while kalan != 0 {
            if let tekrarEdenIndex = kalanlar[kalan] {
                let devretmeyen = String(ondalikKisim.prefix(tekrarEdenIndex))
                let devreden = String(ondalikKisim.suffix(ondalikKisim.count - tekrarEdenIndex))
                
                ekranYazisi = sonuc + devretmeyen + devreden
                devredenUzunluk = devreden.count
                return
            }
            
            kalanlar[kalan] = ondalikKisim.count
            kalan *= 10
            ondalikKisim += "\(kalan / d)"
            kalan %= d
            
            if ondalikKisim.count > 12 {
                ekranYazisi = formatla(pay / payda)
                devredenUzunluk = 0
                return
            }
        }
        
        ekranYazisi = sonuc + ondalikKisim
        devredenUzunluk = 0
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
