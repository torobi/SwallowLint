//
//  PropertyOrderRuleTest.swift
//  swallowlint
//
//  Created by torobi on 2024/09/23.
//

@testable import swallowlint
import Nimble
import Quick

final class PropertyOrderRuleTest: QuickSpec {
    typealias Violation = PropertyOrderRuleTestHelper.TestableViolation
    override class func spec() {
        describe("PropertyOrderRule") {
            context("Class property") {
                it("No violations") {
                    let file = MockSwallowLintFile(source: """
                    class Target {
                        open static let openStaticLet: Int
                        open static var openStaticVar: Int
                        @IBOutlet open static var iboutletOpenStaticVar: Int
                        @IBOutlet open static weak var iboutletOpenStaticWeakVar: Int
                        open static weak var openStaticWeakVar: Int
                        open static lazy var openStaticLazyVar: Int
                        
                        public static let publicStaticLet: Int
                        public static var publicStaticVar: Int
                        @IBOutlet public static var iboutletPublicStaticVar: Int    
                        @IBOutlet public static weak var iboutletPublicStaticWeakVar: Int
                        public static weak var publicStaticWeakVar: Int
                        public static lazy var publicStaticLazyVar: Int
                        
                        package static let packageStaticLet: Int
                        package static var packageStaticVar: Int
                        @IBOutlet package static var iboutletPackageStaticVar: Int    
                        @IBOutlet package static weak var iboutletPackageStaticWeakVar: Int
                        package static weak var packageStaticWeakVar: Int
                        package static lazy var packageStaticLazyVar: Int
                        
                        internal static let internalStaticLet: Int
                        static var internalStaticVar: Int
                        @IBOutlet internal static var iboutletInternalStaticVar: Int    
                        @IBOutlet static weak var iboutletInternalStaticWeakVar: Int
                        internal static weak var internalStaticWeakVar: Int
                        static lazy var internalStaticLazyVar: Int
                    
                        fileprivate static let fileprivateStaticLet: Int
                        fileprivate static var fileprivateStaticVar: Int
                        @IBOutlet fileprivate static var iboutletFileprivateStaticVar: Int    
                        @IBOutlet fileprivate static weak var iboutletFileprivateStaticWeakVar: Int
                        fileprivate static weak var fileprivateStaticWeakVar: Int
                        fileprivate static lazy var fileprivateStaticLazyVar: Int
                    
                        private static let privateStaticLet: Int
                        private static var privateStaticVar: Int
                        @IBOutlet private static var iboutletPrivateStaticVar: Int    
                        @IBOutlet private static weak var iboutletPrivateStaticWeakVar: Int
                        private static weak var privateStaticWeakVar: Int
                        private static lazy var privateStaticLazyVar: Int
                    
                        open let openLet: Int
                        open var openVar: Int
                        @IBOutlet open  var iboutletOpenVar: Int
                        @IBOutlet open  weak var iboutletOpenWeakVar: Int
                        open  weak var openWeakVar: Int
                        open  lazy var openLazyVar: Int
                        
                        public  let publicLet: Int
                        public  var publicVar: Int
                        @IBOutlet public  var iboutletPublicVar: Int    
                        @IBOutlet public  weak var iboutletPublicWeakVar: Int
                        public  weak var publicWeakVar: Int
                        public  lazy var publicLazyVar: Int
                        
                        package  let packageLet: Int
                        package  var packageVar: Int
                        @IBOutlet package  var iboutletPackageVar: Int    
                        @IBOutlet package  weak var iboutletPackageWeakVar: Int
                        package  weak var packageWeakVar: Int
                        package  lazy var packageLazyVar: Int
                        
                        internal  let internalLet: Int
                        var internalVar: Int
                        @IBOutlet internal  var iboutletInternalVar: Int    
                        @IBOutlet  weak var iboutletInternalWeakVar: Int
                        internal  weak var internalWeakVar: Int
                        lazy var internalLazyVar: Int
                    
                        fileprivate  let fileprivateLet: Int
                        fileprivate  var fileprivateVar: Int
                        @IBOutlet fileprivate  var iboutletFileprivateVar: Int    
                        @IBOutlet fileprivate  weak var iboutletFileprivateWeakVar: Int
                        fileprivate  weak var fileprivateWeakVar: Int
                        fileprivate  lazy var fileprivateLazyVar: Int
                    
                        private  let privateLet: Int
                        private  var privateVar: Int
                        @IBOutlet private  var iboutletPrivateVar: Int    
                        @IBOutlet private  weak var iboutletPrivateWeakVar: Int
                        private  weak var privateWeakVar: Int
                        private  lazy var privateLazyVar: Int
                    }
                    """)
                    let rule = PropertyOrderRule()
                    let visitor = rule.makeVisitor(configPath: "", file: file)
                    visitor.walk()
                    expect(visitor.violations.isEmpty) == true
                }
                it("Incorrect order by static parameters") {
                    let file = MockSwallowLintFile(source: """
                    class Target {
                        public let let1: Int
                        var var1: Int
                        static var staticVar: Int
                    }
                    """)
                    let rule = PropertyOrderRule()
                    let visitor = rule.makeVisitor(configPath: "", file: file)
                    visitor.walk()
                    expect(visitor.violations.map { Violation.make($0) }) == [
                        Violation.make(violationLine: 4, below: .static, above: .public, aboveLine: 2),
                        Violation.make(violationLine: 4, below: .static, above: .internal, aboveLine: 3)
                    ]
                }
                it("Incorrect order by access level") {
                    let file = MockSwallowLintFile(source: """
                    class Target {
                        private let privateLet: Int
                        fileprivate let fileprivateLet: Int
                        internal let internalLet: Int    
                        package let packageLet: Int
                        public let publicLet: Int
                        open let openLet: Int
                    }
                    """)
                    let rule = PropertyOrderRule()
                    let visitor = rule.makeVisitor(configPath: "", file: file)
                    visitor.walk()
                    expect(visitor.violations.map { Violation.make($0) }) == [
                        Violation.make(violationLine: 3, below: .fileprivate, above: .private, aboveLine: 2),
                        Violation.make(violationLine: 4, below: .internal, above: .private, aboveLine: 2),
                        Violation.make(violationLine: 5, below: .package, above: .private, aboveLine: 2),
                        Violation.make(violationLine: 6, below: .public, above: .private, aboveLine: 2),
                        Violation.make(violationLine: 7, below: .open, above: .private, aboveLine: 2),
                        Violation.make(violationLine: 4, below: .internal, above: .fileprivate, aboveLine: 3),
                        Violation.make(violationLine: 5, below: .package, above: .fileprivate, aboveLine: 3),
                        Violation.make(violationLine: 6, below: .public, above: .fileprivate, aboveLine: 3),
                        Violation.make(violationLine: 7, below: .open, above: .fileprivate, aboveLine: 3),
                        Violation.make(violationLine: 5, below: .package, above: .internal, aboveLine: 4),
                        Violation.make(violationLine: 6, below: .public, above: .internal, aboveLine: 4),
                        Violation.make(violationLine: 7, below: .open, above: .internal, aboveLine: 4),
                        Violation.make(violationLine: 6, below: .public, above: .package, aboveLine: 5),
                        Violation.make(violationLine: 7, below: .open, above: .package, aboveLine: 5),
                        Violation.make(violationLine: 7, below: .open, above: .public, aboveLine: 6),
                        
                    ]
                }
                it("Incorrect order by let/ver") {
                    let file = MockSwallowLintFile(source: """
                    class Target {
                        var var1: Int
                        let let1: Int
                        var var2: Int
                    }
                    """)
                    let rule = PropertyOrderRule()
                    let visitor = rule.makeVisitor(configPath: "", file: file)
                    visitor.walk()
                    expect(visitor.violations.map { Violation.make($0) }) == [
                        Violation.make(violationLine: 3, below: .let, above: .var, aboveLine: 2),
                    ]
                }
                context("Separeted by MARK") {
                    it("Incorrect order by let/ver") {
                        let file = MockSwallowLintFile(source: """
                        class Target {
                            // MARK: - Separator1
                            var var1_1: Int
                            let let1_1: Int
                            var var1_2: Int
                            // MARK: Separator2
                            var var2_1: Int
                            let let2_1: Int
                            // MARK: IgnroredSeparetor
                            var var2_2: Int
                            // MARK: - Separator3
                            // MARK: Separator4
                            let let3_1: Int
                            let let3_2: Int
                            let let3_3: Int
                        }
                        """)
                        let rule = PropertyOrderRule()
                        let config = PropertyOrderRuleConfig(rule_configs: .init(property_order: .init(separator_marks: [
                            "Separator1",
                            "Separator2",
                            "Separator3",
                            "Separator4",
                            "Separator5"
                        ])))
                        let visitor = rule.makeVisitor(config: config, file: file)
                        visitor.walk()
                        expect(visitor.violations.map { Violation.make($0) }) == [
                            Violation.make(violationLine: 4, below: .let, above: .var, aboveLine: 3),
                            Violation.make(violationLine: 8, below: .let, above: .var, aboveLine: 7)
                        ]
                    }
                }
                context("extension") {
                    it("No violations") {
                        let file = MockSwallowLintFile(source: """
                        extension Target {
                            open static let openStaticLet: Int
                            open static var openStaticVar: Int
                            @IBOutlet open static var iboutletOpenStaticVar: Int
                            @IBOutlet open static weak var iboutletOpenStaticWeakVar: Int
                            open static weak var openStaticWeakVar: Int
                            open static lazy var openStaticLazyVar: Int
                            
                            public static let publicStaticLet: Int
                            public static var publicStaticVar: Int
                            @IBOutlet public static var iboutletPublicStaticVar: Int    
                            @IBOutlet public static weak var iboutletPublicStaticWeakVar: Int
                            public static weak var publicStaticWeakVar: Int
                            public static lazy var publicStaticLazyVar: Int
                            
                            package static let packageStaticLet: Int
                            package static var packageStaticVar: Int
                            @IBOutlet package static var iboutletPackageStaticVar: Int    
                            @IBOutlet package static weak var iboutletPackageStaticWeakVar: Int
                            package static weak var packageStaticWeakVar: Int
                            package static lazy var packageStaticLazyVar: Int
                            
                            internal static let internalStaticLet: Int
                            static var internalStaticVar: Int
                            @IBOutlet internal static var iboutletInternalStaticVar: Int    
                            @IBOutlet static weak var iboutletInternalStaticWeakVar: Int
                            internal static weak var internalStaticWeakVar: Int
                            static lazy var internalStaticLazyVar: Int
                        
                            fileprivate static let fileprivateStaticLet: Int
                            fileprivate static var fileprivateStaticVar: Int
                            @IBOutlet fileprivate static var iboutletFileprivateStaticVar: Int    
                            @IBOutlet fileprivate static weak var iboutletFileprivateStaticWeakVar: Int
                            fileprivate static weak var fileprivateStaticWeakVar: Int
                            fileprivate static lazy var fileprivateStaticLazyVar: Int
                        
                            private static let privateStaticLet: Int
                            private static var privateStaticVar: Int
                            @IBOutlet private static var iboutletPrivateStaticVar: Int    
                            @IBOutlet private static weak var iboutletPrivateStaticWeakVar: Int
                            private static weak var privateStaticWeakVar: Int
                            private static lazy var privateStaticLazyVar: Int
                        
                            open let openLet: Int
                            open var openVar: Int
                            @IBOutlet open  var iboutletOpenVar: Int
                            @IBOutlet open  weak var iboutletOpenWeakVar: Int
                            open  weak var openWeakVar: Int
                            open  lazy var openLazyVar: Int
                            
                            public  let publicLet: Int
                            public  var publicVar: Int
                            @IBOutlet public  var iboutletPublicVar: Int    
                            @IBOutlet public  weak var iboutletPublicWeakVar: Int
                            public  weak var publicWeakVar: Int
                            public  lazy var publicLazyVar: Int
                            
                            package  let packageLet: Int
                            package  var packageVar: Int
                            @IBOutlet package  var iboutletPackageVar: Int    
                            @IBOutlet package  weak var iboutletPackageWeakVar: Int
                            package  weak var packageWeakVar: Int
                            package  lazy var packageLazyVar: Int
                            
                            internal  let internalLet: Int
                            var internalVar: Int
                            @IBOutlet internal  var iboutletInternalVar: Int    
                            @IBOutlet  weak var iboutletInternalWeakVar: Int
                            internal  weak var internalWeakVar: Int
                            lazy var internalLazyVar: Int
                        
                            fileprivate  let fileprivateLet: Int
                            fileprivate  var fileprivateVar: Int
                            @IBOutlet fileprivate  var iboutletFileprivateVar: Int    
                            @IBOutlet fileprivate  weak var iboutletFileprivateWeakVar: Int
                            fileprivate  weak var fileprivateWeakVar: Int
                            fileprivate  lazy var fileprivateLazyVar: Int
                        
                            private  let privateLet: Int
                            private  var privateVar: Int
                            @IBOutlet private  var iboutletPrivateVar: Int    
                            @IBOutlet private  weak var iboutletPrivateWeakVar: Int
                            private  weak var privateWeakVar: Int
                            private  lazy var privateLazyVar: Int
                        }
                        """)
                        let rule = PropertyOrderRule()
                        let visitor = rule.makeVisitor(configPath: "", file: file)
                        visitor.walk()
                        expect(visitor.violations.isEmpty) == true
                    }
                }
            }
            context("Struct property") {
                it("No violations") {
                    let file = MockSwallowLintFile(source: """
                    struct Target {
                        open static let openStaticLet: Int
                        open static var openStaticVar: Int
                        @IBOutlet open static var iboutletOpenStaticVar: Int
                        @IBOutlet open static weak var iboutletOpenStaticWeakVar: Int
                        open static weak var openStaticWeakVar: Int
                        open static lazy var openStaticLazyVar: Int
                        
                        public static let publicStaticLet: Int
                        public static var publicStaticVar: Int
                        @IBOutlet public static var iboutletPublicStaticVar: Int    
                        @IBOutlet public static weak var iboutletPublicStaticWeakVar: Int
                        public static weak var publicStaticWeakVar: Int
                        public static lazy var publicStaticLazyVar: Int
                        
                        package static let packageStaticLet: Int
                        package static var packageStaticVar: Int
                        @IBOutlet package static var iboutletPackageStaticVar: Int    
                        @IBOutlet package static weak var iboutletPackageStaticWeakVar: Int
                        package static weak var packageStaticWeakVar: Int
                        package static lazy var packageStaticLazyVar: Int
                        
                        internal static let internalStaticLet: Int
                        static var internalStaticVar: Int
                        @IBOutlet internal static var iboutletInternalStaticVar: Int    
                        @IBOutlet static weak var iboutletInternalStaticWeakVar: Int
                        internal static weak var internalStaticWeakVar: Int
                        static lazy var internalStaticLazyVar: Int
                    
                        fileprivate static let fileprivateStaticLet: Int
                        fileprivate static var fileprivateStaticVar: Int
                        @IBOutlet fileprivate static var iboutletFileprivateStaticVar: Int    
                        @IBOutlet fileprivate static weak var iboutletFileprivateStaticWeakVar: Int
                        fileprivate static weak var fileprivateStaticWeakVar: Int
                        fileprivate static lazy var fileprivateStaticLazyVar: Int
                    
                        private static let privateStaticLet: Int
                        private static var privateStaticVar: Int
                        @IBOutlet private static var iboutletPrivateStaticVar: Int    
                        @IBOutlet private static weak var iboutletPrivateStaticWeakVar: Int
                        private static weak var privateStaticWeakVar: Int
                        private static lazy var privateStaticLazyVar: Int
                    
                        open let openLet: Int
                        open var openVar: Int
                        @IBOutlet open  var iboutletOpenVar: Int
                        @IBOutlet open  weak var iboutletOpenWeakVar: Int
                        open  weak var openWeakVar: Int
                        open  lazy var openLazyVar: Int
                        
                        public  let publicLet: Int
                        public  var publicVar: Int
                        @IBOutlet public  var iboutletPublicVar: Int    
                        @IBOutlet public  weak var iboutletPublicWeakVar: Int
                        public  weak var publicWeakVar: Int
                        public  lazy var publicLazyVar: Int
                        
                        package  let packageLet: Int
                        package  var packageVar: Int
                        @IBOutlet package  var iboutletPackageVar: Int    
                        @IBOutlet package  weak var iboutletPackageWeakVar: Int
                        package  weak var packageWeakVar: Int
                        package  lazy var packageLazyVar: Int
                        
                        internal  let internalLet: Int
                        var internalVar: Int
                        @IBOutlet internal  var iboutletInternalVar: Int    
                        @IBOutlet  weak var iboutletInternalWeakVar: Int
                        internal  weak var internalWeakVar: Int
                        lazy var internalLazyVar: Int
                    
                        fileprivate  let fileprivateLet: Int
                        fileprivate  var fileprivateVar: Int
                        @IBOutlet fileprivate  var iboutletFileprivateVar: Int    
                        @IBOutlet fileprivate  weak var iboutletFileprivateWeakVar: Int
                        fileprivate  weak var fileprivateWeakVar: Int
                        fileprivate  lazy var fileprivateLazyVar: Int
                    
                        private  let privateLet: Int
                        private  var privateVar: Int
                        @IBOutlet private  var iboutletPrivateVar: Int    
                        @IBOutlet private  weak var iboutletPrivateWeakVar: Int
                        private  weak var privateWeakVar: Int
                        private  lazy var privateLazyVar: Int
                    }
                    """)
                    let rule = PropertyOrderRule()
                    let visitor = rule.makeVisitor(configPath: "", file: file)
                    visitor.walk()
                    expect(visitor.violations.isEmpty) == true
                }
            }
            context("Enum property") {
                it("No violations") {
                    let file = MockSwallowLintFile(source: """
                    enum Target {
                        open static let openStaticLet: Int
                        open static var openStaticVar: Int
                        @IBOutlet open static var iboutletOpenStaticVar: Int
                        @IBOutlet open static weak var iboutletOpenStaticWeakVar: Int
                        open static weak var openStaticWeakVar: Int
                        open static lazy var openStaticLazyVar: Int
                        
                        public static let publicStaticLet: Int
                        public static var publicStaticVar: Int
                        @IBOutlet public static var iboutletPublicStaticVar: Int    
                        @IBOutlet public static weak var iboutletPublicStaticWeakVar: Int
                        public static weak var publicStaticWeakVar: Int
                        public static lazy var publicStaticLazyVar: Int
                        
                        package static let packageStaticLet: Int
                        package static var packageStaticVar: Int
                        @IBOutlet package static var iboutletPackageStaticVar: Int    
                        @IBOutlet package static weak var iboutletPackageStaticWeakVar: Int
                        package static weak var packageStaticWeakVar: Int
                        package static lazy var packageStaticLazyVar: Int
                        
                        internal static let internalStaticLet: Int
                        static var internalStaticVar: Int
                        @IBOutlet internal static var iboutletInternalStaticVar: Int    
                        @IBOutlet static weak var iboutletInternalStaticWeakVar: Int
                        internal static weak var internalStaticWeakVar: Int
                        static lazy var internalStaticLazyVar: Int
                    
                        fileprivate static let fileprivateStaticLet: Int
                        fileprivate static var fileprivateStaticVar: Int
                        @IBOutlet fileprivate static var iboutletFileprivateStaticVar: Int    
                        @IBOutlet fileprivate static weak var iboutletFileprivateStaticWeakVar: Int
                        fileprivate static weak var fileprivateStaticWeakVar: Int
                        fileprivate static lazy var fileprivateStaticLazyVar: Int
                    
                        private static let privateStaticLet: Int
                        private static var privateStaticVar: Int
                        @IBOutlet private static var iboutletPrivateStaticVar: Int    
                        @IBOutlet private static weak var iboutletPrivateStaticWeakVar: Int
                        private static weak var privateStaticWeakVar: Int
                        private static lazy var privateStaticLazyVar: Int
                    
                        open let openLet: Int
                        open var openVar: Int
                        @IBOutlet open  var iboutletOpenVar: Int
                        @IBOutlet open  weak var iboutletOpenWeakVar: Int
                        open  weak var openWeakVar: Int
                        open  lazy var openLazyVar: Int
                        
                        public  let publicLet: Int
                        public  var publicVar: Int
                        @IBOutlet public  var iboutletPublicVar: Int    
                        @IBOutlet public  weak var iboutletPublicWeakVar: Int
                        public  weak var publicWeakVar: Int
                        public  lazy var publicLazyVar: Int
                        
                        package  let packageLet: Int
                        package  var packageVar: Int
                        @IBOutlet package  var iboutletPackageVar: Int    
                        @IBOutlet package  weak var iboutletPackageWeakVar: Int
                        package  weak var packageWeakVar: Int
                        package  lazy var packageLazyVar: Int
                        
                        internal  let internalLet: Int
                        var internalVar: Int
                        @IBOutlet internal  var iboutletInternalVar: Int    
                        @IBOutlet  weak var iboutletInternalWeakVar: Int
                        internal  weak var internalWeakVar: Int
                        lazy var internalLazyVar: Int
                    
                        fileprivate  let fileprivateLet: Int
                        fileprivate  var fileprivateVar: Int
                        @IBOutlet fileprivate  var iboutletFileprivateVar: Int    
                        @IBOutlet fileprivate  weak var iboutletFileprivateWeakVar: Int
                        fileprivate  weak var fileprivateWeakVar: Int
                        fileprivate  lazy var fileprivateLazyVar: Int
                    
                        private  let privateLet: Int
                        private  var privateVar: Int
                        @IBOutlet private  var iboutletPrivateVar: Int    
                        @IBOutlet private  weak var iboutletPrivateWeakVar: Int
                        private  weak var privateWeakVar: Int
                        private  lazy var privateLazyVar: Int
                    }
                    """)
                    let rule = PropertyOrderRule()
                    let visitor = rule.makeVisitor(configPath: "", file: file)
                    visitor.walk()
                    expect(visitor.violations.isEmpty) == true
                }
            }
        }
    }
}
