import XMLCoder

/// A container used to group other SVG elements.
///
/// Grouping constructs, when used in conjunction with the ‘desc’ and ‘title’ elements, provide information
/// about document structure and semantics.
///
/// ## Documentation
/// [Mozilla Developer Network](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/g)
/// | [W3](https://www.w3.org/TR/SVG11/struct.html#Groups)
public struct Group: Container, Element {
    
    // Container
    public var circles: [Circle]?
    public var ellipses: [Ellipse]?
    public var groups: [Group]?
    public var lines: [Line]?
    public var paths: [Path]?
    public var polygons: [Polygon]?
    public var polylines: [Polyline]?
    public var rectangles: [Rectangle]?
    public var texts: [Text]?
    
    // CoreAttributes
    public var id: String?
    
    // PresentationAttributes
    public var fillColor: String?
    public var fillOpacity: Double?
    public var fillRule: Fill.Rule?
    public var strokeColor: String?
    public var strokeWidth: Double?
    public var strokeOpacity: Double?
    public var strokeLineCap: Stroke.LineCap?
    public var strokeLineJoin: Stroke.LineJoin?
    public var strokeMiterLimit: Double?
    public var transform: String?
    
    // StylingAttributes
    public var style: String?
    
    enum CodingKeys: String, CodingKey {
        case circles = "circle"
        case ellipses = "ellipse"
        case groups = "g"
        case lines = "line"
        case paths = "path"
        case polylines = "polyline"
        case polygons = "polygon"
        case rectangles = "rect"
        case texts = "text"
        case id
        case fillColor = "fill"
        case fillOpacity = "fill-opacity"
        case fillRule = "fill-rule"
        case strokeColor = "stroke"
        case strokeWidth = "stroke-width"
        case strokeOpacity = "stroke-opacity"
        case strokeLineCap = "stroke-linecap"
        case strokeLineJoin = "stroke-linejoin"
        case strokeMiterLimit = "stroke-miterlimit"
        case transform
        case style
    }
    
    public init() {
    }
    
    // MARK: - CustomStringConvertible
    public var description: String {
        return "<g \(attributeDescription) >\(containerDescription)\n</g>"
    }
}

// MARK: - DynamicNodeEncoding
extension Group: DynamicNodeEncoding {
    public static func nodeEncoding(for key: CodingKey) -> XMLEncoder.NodeEncoding {
        if let _ = ContainerKeys(stringValue: key.stringValue) {
            return .element
        }
        
        return .attribute
    }
}

// MARK: - DynamicNodeDecoding
extension Group: DynamicNodeDecoding {
    public static func nodeDecoding(for key: CodingKey) -> XMLDecoder.NodeDecoding {
        if let _ = ContainerKeys(stringValue: key.stringValue) {
            return .element
        }
        
        return .attribute
    }
}

// MARK: - Paths
public extension Group {
    /// A representation of all the sub-`Path`s in the `Group`.
    func subpaths(applying transformations: [Transformation] = [], parentStroke: Stroke?, parentFill: Fill?) throws -> [Path] {
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

        //Apply styling from the style attribute
        if let style = style {
            let components = style.split(separator: ";")
            let properties = Dictionary(components.map({ component in
                let keyAndValue = component.split(separator: ":")
                return (keyAndValue[0], keyAndValue[1])
            }),
            uniquingKeysWith: {_, new in new})

            for property in properties {
                switch property.key {
                case "stroke": stroke.color = String(property.value)
                case "stoke-width": stroke.width = Double(property.value)!
                case "stroke-opacity":  stroke.opacity = Double(property.value)!
                case "stroke-linecap": stroke.lineCap = Stroke.LineCap(rawValue: String(property.value))!
                case "stroke-linejoin": stroke.lineJoin = Stroke.LineJoin(rawValue: String(property.value))!
                case "stroke-miterlimit": stroke.miterLimit = Double(property.value)!
                case "fill": fill.color = String(property.value)
                case "fill-opacity": fill.opacity = Double(property.value)!
                case "fill-rule": fill.rule = Fill.Rule(rawValue: String(property.value))!
                default: continue
                }
            }
        }

        //Consolidate stroke and fill with possible parent values
        if let parent = parentStroke {
            stroke.inherit(from: parent)
        }
        if let parent = parentFill {
            fill.inherit(from: parent)
        }

        //Get subpaths
        var output: [Path] = []
        
        if let circles = self.circles {
            try output.append(contentsOf: circles.compactMap({ try $0.path(applying: _transformations, parentStroke: stroke, parentFill: fill) }))
        }
        
        if let ellipses = self.ellipses {
            try output.append(contentsOf: ellipses.compactMap({ try $0.path(applying: _transformations, parentStroke: stroke, parentFill: fill) }))
        }
        
        if let rectangles = self.rectangles {
            try output.append(contentsOf: rectangles.compactMap({ try $0.path(applying: _transformations, parentStroke: stroke, parentFill: fill) }))
        }
        
        if let polygons = self.polygons {
            try output.append(contentsOf: polygons.compactMap({ try $0.path(applying: _transformations, parentStroke: stroke, parentFill: fill) }))
        }
        
        if let polylines = self.polylines {
            try output.append(contentsOf: polylines.compactMap({ try $0.path(applying: _transformations, parentStroke: stroke, parentFill: fill) }))
        }
        
        if let paths = self.paths {
            try output.append(contentsOf: paths.map({ try $0.path(applying: _transformations, parentStroke: stroke, parentFill: fill) }))
        }
        
        if let groups = self.groups {
            try groups.forEach({
                try output.append(contentsOf: $0.subpaths(applying: _transformations, parentStroke: stroke, parentFill: fill))
            })
        }
        
        return output
    }
}
