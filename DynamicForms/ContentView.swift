//
//  ContentView.swift
//  DynamicForms
//
//

import SwiftUI
import Combine

struct DynamicFormView: View {
    @StateObject var dynamicViewModel = DynamicViewModel()
    
    @State private var values: [String: Any] = [:]
    @State private var buttonClicked: Bool = false
    
    var body: some View {
        
        VStack{
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text(dynamicViewModel.form.formTitle)
                        .font(.title3)
                        .foregroundStyle(Color.init(hex: dynamicViewModel.form.theme.textColor))
                    
                    ForEach(dynamicViewModel.form.fields.sorted(by: {
                        $0.order < $1.order
                    })) { field in
                        
                        DynamicFieldView(
                            buttonClicked: $buttonClicked, field: field,
                            values: $values
                        )
                    }
                    
                    
                    Button {
                        print(values)
                        buttonClicked.toggle()
                    } label: {
                        Text("Submit")
                            .font(.title3)
                            .foregroundStyle(Color.init(hex: dynamicViewModel.form.theme.textColor))
                    }
                    
                }                .padding()
            }
        }.frame(maxWidth: .infinity)
            .background(Color.init(hex: dynamicViewModel.form.theme.backgroundColor))
        
    }
}

struct DynamicFieldView: View {
    @StateObject var dynamicViewModel = DynamicViewModel()
    @Binding var buttonClicked: Bool
    let field: Field
    
    @Binding var values: [String: Any]
    
    var body: some View {
        
        VStack(alignment: .leading){
            switch field.type {
                
            case .text:
                textFieldView
                
            case .dropdown:
                let options = field.options ?? []
                if !options.isEmpty {
                    dropdownView
                }
                
            case .checkbox:
                checkboxView
                
            case .toggle:
                toggleView
                
            case .colorPicker:
                colorPickerView
            }
            
            if !isFieldValid && buttonClicked{
                
                Text(field.errorMessage ?? "This field is required")
                    .font(.caption)
                    .foregroundStyle(Color.init(hex: dynamicViewModel.form.theme.errorColor))
            }
        }
    }
    
    private var textBinding: Binding<String> {
        Binding(
            get: {
                values[field.id] as? String ?? ""
            },
            set: { newValue in
                let updatedValue: String
                
                if let maxLength = field.validation?.maxLength {
                    updatedValue = String(newValue.prefix(maxLength))
                } else {
                    updatedValue = newValue
                }
                
                values[field.id] = updatedValue
            }
        )
    }
    
    @ViewBuilder
    private var textFieldView: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(field.label)
                .font(.headline)
                .foregroundStyle(
                    Color(hex: dynamicViewModel.form.theme.textColor)
                )
            
            fieldView
            
            if let maxLength = field.validation?.maxLength {
                HStack {
                    Spacer()
                    
                    Text("\(textBinding.wrappedValue.count)/\(maxLength)")
                        .font(.caption)
                        .foregroundStyle(Color.init(hex: dynamicViewModel.form.theme.errorColor))
                }
            }
        }
    }
    
    @ViewBuilder
    private var fieldView: some View {
        
        switch field.subtype {
            
        case .plain:
            
            customTextField
            
        case .multiline:
            
            TextEditor(text: textBinding)
                .frame(minHeight: 120)
                .padding(8)
                .foregroundColor(
                    Color(hex: dynamicViewModel.form.theme.textColor)
                )
                .background(backgroundColor)
                .overlay(borderView)
            
        case .number:
            
            customTextField
                .keyboardType(.numberPad)
            
        case .url:
            
            customTextField
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
        case .secure:
            
            SecureField("", text: textBinding)
                .padding()
                .foregroundColor(
                    Color(hex: dynamicViewModel.form.theme.textColor)
                )
                .background(backgroundColor)
                .overlay(borderView)
            
        case .none:
            
            EmptyView()
        }
    }
    
    private var customTextField: some View {
        
        TextField("", text: textBinding)
            .padding()
            .foregroundColor(
                Color(hex: dynamicViewModel.form.theme.textColor)
            )
            .background(backgroundColor)
            .overlay(borderView)
    }
    
    private var borderView: some View {
        
        RoundedRectangle(cornerRadius: 10)
            .stroke(
                Color(
                    Color(hex: dynamicViewModel.form.theme.borderColor)
                ),
                lineWidth: 1
            )
    }
    
    private var backgroundColor: some View {
        
        RoundedRectangle(cornerRadius: 10)
            .fill(
                Color(
                    hex: dynamicViewModel.form.theme.backgroundColor
                )
            )
    }
    
    private var toggleView: some View {
        
        Toggle(
            field.label,
            isOn: Binding(
                get: {
                    values[field.id] as? Bool ?? false
                },
                set: {
                    values[field.id] = $0
                }
            )
        ).foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
    }
    
    private var dropdownView: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(field.label)
                .font(.headline)
                .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
            
            if field.allowMultiple == true {
                
                MultiSelectDropdownView(
                    field: field,
                    values: $values
                )
                
            } else {
                
                Picker(
                    field.label,
                    selection: Binding(
                        get: {
                            values[field.id] as? String ?? ""
                        },
                        set: {
                            values[field.id] = $0
                        }
                    )
                ) {
                    
                    Text("Select \(field.label)")
                        .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
                        .tag("")
                    
                    ForEach(field.options ?? [], id: \.id) { option in
                        Text(option.label)
                            .tag(option.id)
                            .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }
    private var multiSelectionView: some View {
        
        VStack(spacing: 12) {
            
            ForEach(field.options ?? [], id: \.id) { option in
                
                Button {
                    
                    toggleSelection(option.id)
                    
                } label: {
                    
                    HStack {
                        
                        Text(option.label)
                            .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
                        Spacer()
                        
                        if selectedValues.contains(option.id) {
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            
                        } else {
                            
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var selectedValues: [String] {
        values[field.id] as? [String] ?? []
    }
    
    private func toggleSelection(_ id: String) {
        
        var current = selectedValues
        
        if current.contains(id) {
            current.removeAll { $0 == id }
        } else {
            current.append(id)
        }
        
        values[field.id] = current
    }
    private var checkboxView: some View {
        
        Button {
            
            let current = values[field.id] as? Bool ?? false
            values[field.id] = !current
            
        } label: {
            
            HStack(alignment: .top, spacing: 12) {
                
                Image(
                    systemName:
                        (values[field.id] as? Bool ?? false)
                    ? "checkmark.square.fill"
                    : "square"
                )
                .font(.title3)
                .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
                
                clickableLabelView
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
    
    private var clickableLabelView: some View {
        
        Text(attributedLabel)
            .multilineTextAlignment(.leading)
            .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
    }
    
    private var attributedLabel: AttributedString {
        
        var attributed = AttributedString(field.label)
        
        guard
            let links = field.metadata?.links
        else {
            return attributed
        }
        
        let clickableColor = Color(
            hex: field.metadata?.clickableTextColor ?? "#BB86FC"
        )
        
        for (text, urlString) in links {
            
            guard
                let range = attributed.range(of: text),
                let url = URL(string: urlString)
            else {
                continue
            }
            
            attributed[range].link = url
            attributed[range].foregroundColor = clickableColor
            attributed[range].underlineStyle = .single
        }
        
        return attributed
    }
    
    private var colorPickerView: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            ColorPicker(
                field.label,
                selection: Binding(
                    get: {
                        
                        if let hex = values[field.id] as? String {
                            return Color(hex: hex)
                        }
                        
                        return .blue
                        
                    },
                    set: { newColor in
                        
                        values[field.id] = newColor.toHex()
                    }
                )
            )
            .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
        }
    }
    
    private var isFieldValid: Bool {
        
        guard field.required == true else {
            return true
        }
        
        switch field.type {
            
        case .text:
            
            let value = values[field.id] as? String ?? ""
            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
        case .dropdown:
            
            if field.allowMultiple == true {
                
                let value = values[field.id] as? [String] ?? []
                return !value.isEmpty
                
            } else {
                
                let value = values[field.id] as? String ?? ""
                return !value.isEmpty
            }
            
        case .checkbox:
            
            return values[field.id] as? Bool == true
            
        default:
            return true
        }
    }
    
}

extension Color {
    
    init(hex: String) {
        
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted
        )
        
        var int: UInt64 = 0
        
        Scanner(string: hex).scanHexInt64(&int)
        
        let r, g, b: UInt64
        
        switch hex.count {
            
        case 6:
            (r, g, b) = (
                (int >> 16) & 0xFF,
                (int >> 8) & 0xFF,
                int & 0xFF
            )
            
        default:
            (r, g, b) = (255, 255, 255)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

extension Color {
    
    func toHex() -> String {
        
        UIColor(self)
            .cgColor
            .components?
            .prefix(3)
            .map {
                String(format: "%02lX",
                       lround(Double($0) * 255))
            }
            .joined() ?? "FFFFFF"
    }
}

struct MultiSelectDropdownView: View {
    @StateObject var dynamicViewModel = DynamicViewModel()
    
    let field: Field
    @Binding var values: [String: Any]
    
    @State private var showOptions = false
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Button {
                
                showOptions.toggle()
                
            } label: {
                
                HStack {
                    
                    Text(displayText)
                    
                        .foregroundColor(Color.init(hex: dynamicViewModel.form.theme.textColor))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $showOptions) {
                
                multiSelectionSheet
            }
        }
    }
    
    private var displayText: String {
        
        let selectedLabels = field.options?
            .filter { selectedValues.contains($0.id) }
            .map { $0.label } ?? []
        
        return selectedLabels.isEmpty
        ? "Select \(field.label)"
        : selectedLabels.joined(separator: ", ")
    }
    private var multiSelectionSheet: some View {
        
        NavigationView {
            VStack(spacing:0){
                
                Text(field.label)
                    .font(.headline)
                    .foregroundColor(
                        Color(hex: dynamicViewModel.form.theme.textColor)
                    )
                
                
                List(field.options ?? [], id: \.id) { option in
                    
                    Button {
                        
                        toggleSelection(option.id)
                        
                    } label: {
                        
                        HStack {
                            
                            Text(option.label)
                                .foregroundColor(
                                    Color(hex: dynamicViewModel.form.theme.textColor)
                                )
                            
                            Spacer()
                            
                            if selectedValues.contains(option.id) {
                                
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(
                        Color(hex: dynamicViewModel.form.theme.backgroundColor)
                    )
                }
                .scrollContentBackground(.hidden)
                .background(
                    Color(hex: dynamicViewModel.form.theme.backgroundColor)
                )
                
            }
            
            .toolbar {
                
                ToolbarItem(placement: .topBarTrailing) {
                    
                    Button("Done") {
                        showOptions = false
                    }
                }
            }
        }
        .background(
            Color(hex: dynamicViewModel.form.theme.backgroundColor)
        )
    }
    private var selectedValues: [String] {
        values[field.id] as? [String] ?? []
    }
    private func toggleSelection(_ id: String) {
        
        var current = selectedValues
        
        if current.contains(id) {
            
            current.removeAll { $0 == id }
            
        } else {
            
            current.append(id)
        }
        
        values[field.id] = current
    }
}
