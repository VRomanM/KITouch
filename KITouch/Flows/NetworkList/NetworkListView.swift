//
//  NetworkListView.swift
//  KITouch
//
//  Created by Роман Вертячих on 02.06.2025.
//

import SwiftUI

struct NetworkListView: View {
    @StateObject var viewModel: ContactDetailViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    ForEach($viewModel.networks) { $network in
                        HStack {
                            TextField(text: $network.login, label: { Text("Enter login") })
                                .padding()
                            Picker(selection: $network.network, label:
                                    Label(title: {}, icon: {
                                HStack {
                                    Spacer()
                                    Image(network.network.icon)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                    Spacer()
                                }
                            })) {
                                ForEach(Network.allCases) { network in
                                    Text(network.rawValue)
                                        .tag(network)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    Button {
                        
                    } label: {
                        Text("Save")
                            .font(.headline)
                            .frame(width: 280, height: 50)
                            .background(.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .navigationTitle("Networks")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            //showingAddSheet = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NetworkListView(viewModel: ContactDetailViewModel())
}
