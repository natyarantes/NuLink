//
//  ShortenerView.swift
//  NuLink
//
//  Created by Natália Arantes on 03/10/25.
//

import SwiftUI

struct ShortenerView: View {
    
    @ObservedObject var vm: ShortenerViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.openURL) private var openURL
    @State private var showCopiedToast = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DSMetrics.paddingL) {
                inputSection
                actionButton
                contentSection
            }
            .padding(.horizontal, DSMetrics.paddingL)
            .padding(.top, 20)
            .background(DS.Bg.app.ignoresSafeArea())
            .navigationTitle("NuLink")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            vm.clearAll()
                        } label: {
                            Label("Limpar histórico", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .onTapGesture { isFocused = false }
        .toast(isPresented: $showCopiedToast, text: "Link copiado!")
    }
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: DSMetrics.paddingS) {
            Text("Cole ou digite a URL")
                .font(DSType.section)
                .foregroundColor(DS.Text.secondary)
            
            HStack(spacing: DSMetrics.paddingS) {
                TextField("https://exemplo.com", text: $vm.inputText)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($isFocused)
                    .accessibilityIdentifier("urlInputField")
                    .nuField()
                
                if !vm.inputText.isEmpty {
                    Button {
                        vm.inputText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(DS.Text.secondary)
                            .font(.title3)
                    }
                    .accessibilityLabel("Limpar texto")
                }
            }
        }
    }
    
    private var actionButton: some View {
        let isDisabled = vm.isLoading || vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        return Button {
            isFocused = false
            Task { await vm.shorten() }
        } label: {
            if vm.isLoading {
                ProgressView()
            } else {
                Text("Encurtar link")
            }
        }
        .buttonStyle(NuPrimaryButtonStyle())
        .disabled(isDisabled)
        .accessibilityIdentifier("shortenerButton")
    }
    
    @ViewBuilder
    private var contentSection: some View {
        if vm.items.isEmpty {
            emptyState
        } else {
            listSection
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 48, weight: .semibold))
                .foregroundStyle(DS.Accent.subtle)
            Text("Não há link")
                .font(DSType.title)
            Text("Cole um endereço acima e toque em “Encurtar link”.")
                .font(DSType.body)
                .foregroundStyle(DS.Text.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 24)
    }
    
    private var listSection: some View {
        List {
            Section("Recentes") {
                ForEach(vm.items) { item in
                    NuCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.shortURL)
                                .font(.headline)
                                .foregroundStyle(DS.Accent.primary)
                            
                            Text(item.originalURL)
                                .font(DSType.body)
                                .foregroundStyle(DS.Text.secondary)
                                .lineLimit(2)
                            
                            Text(item.alias)
                                .font(DSType.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let url = URL(string: item.shortURL) { openURL(url) }
                    }
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = item.shortURL
                            showCopiedToast = true
                        } label: {
                            Label("Copiar link curto", systemImage: "doc.on.doc")
                        }
                        if let url = URL(string: item.shortURL) {
                            ShareLink(item: url) { Label("Compartilhar", systemImage: "square.and.arrow.up") }
                        }
                        Button(role: .destructive) {
                            vm.delete(itemID: item.id)
                        } label: {
                            Label("Excluir", systemImage: "trash")
                        }
                    }
                }
                .onDelete { idx in
                    idx.map { vm.items[$0].id }.forEach(vm.delete(itemID:))
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}


// MARK: - Toast simples
private struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let text: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                Text(text)
                    .font(DSType.caption)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: Capsule())
                    .shadow(radius: 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation { isPresented = false }
                        }
                    }
                    .padding(.top, 8)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isPresented)
    }
}
private extension View {
    func toast(isPresented: Binding<Bool>, text: String) -> some View {
        modifier(ToastModifier(isPresented: isPresented, text: text))
    }
}

// MARK: - Preview com dados mock
#Preview {
    let vm = ShortenerViewModel()
    vm.items = [
        ShortItemViewData(
            originalURL: "https://nubank.com.br/alguma-pagina",
            shortURL: "https://sho.rt/abc123",
            alias: "abc123"
        ) as ShortItemViewData,
        ShortItemViewData(
            originalURL: "https://apple.com",
            shortURL: "https://sho.rt/xyz987",
            alias: "xyz987"
        ) as ShortItemViewData
    ]
    return NavigationStack { ShortenerView(vm: vm) }
}
