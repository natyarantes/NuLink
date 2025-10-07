//
//  ShortenerView.swift
//  NuLink
//
//  Created by Natália Arantes on 03/10/25.
//

import SwiftUI
import UIKit

struct ShortenerView: View {

    @ObservedObject var vm: ShortenerViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.openURL) private var openURL
    @State private var showCopiedToast = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: DSMetrics.paddingL) {
                    inputSection
                    actionButton
                }
                .padding(.horizontal, DSMetrics.paddingL)
                .padding(.vertical, 20)
                .background(DS.Bg.app)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .zIndex(1)
                contentSection
            }
            .navigationTitle("NuLink")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            vm.reset()
                        } label: {
                            Label("Limpar tudo", systemImage: "trash")
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
                TextField("https://exemplo.com", text: $vm.inputURL)
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .focused($isFocused)
                    .accessibilityIdentifier("urlInputField")
                    .nuField()

                if !vm.inputURL.isEmpty {
                    Button {
                        vm.inputURL = ""
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
        let isDisabled = vm.isLoading || vm.inputURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        return Button {
            isFocused = false
            vm.shorten()
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
        if let message = vm.errorMessage {
            errorState(message)
        } else if vm.items.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: DSMetrics.paddingM) {
                    ForEach(vm.items) { item in
                        NuCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(item.short)
                                    .font(.headline)
                                    .foregroundStyle(DS.Accent.primary)
                                    .textSelection(.enabled)

                                Text(item.original)
                                    .font(DSType.body)
                                    .foregroundStyle(DS.Text.secondary)
                                    .lineLimit(2)
                                    .textSelection(.enabled)

                                HStack(spacing: 12) {
                                    Button {
                                        UIPasteboard.general.string = item.short
                                        showCopiedToast = true
                                    } label: {
                                        Label("Copiar", systemImage: "doc.on.doc")
                                    }

                                    if let url = URL(string: item.short) {
                                        Button {
                                            openURL(url)
                                        } label: {
                                            Label("Abrir", systemImage: "safari")
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                                .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.items)
                    }
                }
                .padding(.horizontal, DSMetrics.paddingL)
                .padding(.top, DSMetrics.paddingM)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollDismissesKeyboard(.immediately)
            .background(DS.Bg.app)
        }
    }

// MARK: - States
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

    private func errorState(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40, weight: .semibold))
            Text("Ops, algo deu errado")
                .font(DSType.title)
            Text(message)
                .font(DSType.body)
                .foregroundStyle(DS.Text.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 24)
        .foregroundStyle(.orange)
    }
}

// MARK: - Toast
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
