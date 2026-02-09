import SwiftUI

public struct PrimaryButton: View {
    public enum Size { case large, medium }

    let title: String
    let size: Size
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void

    public init(
        _ title: String,
        size: Size = .large,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.size = size
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.scale)
                } else {
                    Text(title)
                        .font(Tokens.Font.semibold16)
                        .tracking(-0.16.scale)
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, size == .large ? 16.scale : 12.scale)
            .background(
                RoundedRectangle(
                    cornerRadius: Tokens.Radius.medium,
                    style: .continuous
                )
                .fill(isDisabled ? Tokens.Color.accentPressed : Tokens.Color.accent)
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )
            )
           
        }
        .buttonStyle(.plain)
        .disabled(isDisabled || isLoading)
        .accessibilityAddTraits(.isButton)
    }
}
