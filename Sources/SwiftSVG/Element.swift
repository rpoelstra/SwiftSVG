public protocol Element: CoreAttributes, PresentationAttributes, StylingAttributes {
}

public extension Element {
    var attributeDescription: String {
        var components: [String] = []
        
        if !coreDescription.isEmpty {
            components.append(coreDescription)
        }
        if !presentationDescription.isEmpty {
            components.append(presentationDescription)
        }
        if !stylingDescription.isEmpty {
            components.append(stylingDescription)
        }
        
        return components.joined(separator: " ")
    }
}

public extension CommandRepresentable where Self: Element {
    /// When a `Path` is accessed on an element, the path that is returned should have the supplied transformations
    /// applied.
    ///
    /// For instance, if
    /// * a `Path.data` contains relative elements,
    /// * and `transformations` contains a `.translate`
    ///
    /// Than the path created will not only use 'absolute' instructions, but those instructions will be modified to
    /// include the required transformation.
    func path(applying transformations: [Transformation] = [], parentStroke: Stroke?, parentFill: Fill?) throws -> Path {
        var _transformations = transformations
        _transformations.append(contentsOf: self.transformations)

        var stroke = Stroke(color: strokeColor,
                            width: strokeWidth,
                            opacity: strokeOpacity,
                            lineCap: strokeLineCap,
                            lineJoin: strokeLineJoin,
                            miterLimit: strokeMiterLimit)
        var fill = Fill(color: fillColor,
                        opacity: fillOpacity,
                        rule: fillRule)


        if let parent = parentStroke {
            stroke.inherit(from: parent)
        }
        if let parent = parentFill {
            fill.inherit(from: parent)
        }

        let commands = try self.commands().map({ $0.applying(transformations: _transformations) })
        
        var path = Path(commands: commands)
        path.fill = fill
        path.stroke = stroke

        return path
    }
}
