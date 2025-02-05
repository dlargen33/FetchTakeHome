//
//  EmptyDataView.swift
//  FetchTakeHome
//
//  Created by Donald Largen on 2/5/25.
//

import SwiftUI

struct EmptyDataView: View {
    
    var action: () -> ()
    
    var body: some View {
       VStack(spacing: -35) {
               Image("chef-hat")
                   .resizable()
                   .scaledToFit()
                   .frame(width: 300, height: 300)
                   .clipped()
                   
               
               VStack(spacing: 5) {
                   Text("No recipes found.")
                       .font(.system(size: 20,
                                     weight: .semibold,
                                     design: .rounded))
                       .foregroundColor(.white)
                       .multilineTextAlignment(.center)
                   
                   Text("Try refreshing the page.")
                       .font(.system(size: 20,
                                     weight: .regular,
                                     design: .rounded))
                       .foregroundColor(.white)
                       .multilineTextAlignment(.center)
                   
                  
                Button(action: {
                    print("Refresh tapped")
                    action()
                }) {
                       Text("Refresh")
                           .font(.system(size: 18,
                                         weight: .semibold,
                                         design: .rounded))
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                   }
                .padding()
                .padding(.horizontal, 50) // Add horizontal padding
               }
            }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
}

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 12 / 255, green: 26 / 255, blue: 38 / 255),
                Color(red: 18 / 255, green: 34 / 255, blue: 46 / 255),
                Color(red: 24 / 255, green: 40 / 255, blue: 54 / 255)]),
            startPoint: .top,
            endPoint: .bottom)
        .ignoresSafeArea()
        EmptyDataView {
            print("Action")
        }
    }
    
}
