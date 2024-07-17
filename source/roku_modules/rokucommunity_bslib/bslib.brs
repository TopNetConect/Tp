







function rokucommunity_bslib_toString(value)
    valueType = type(value)

    if valueType = "<uninitialized>" then
        return valueType
    else if value = invalid then
        return "<invalid>"
    else if GetInterface(value, "ifToStr") <> invalid then
        return value.toStr()
    else if valueType = "roSGNode"
        return "Node(" + value.subType() + ")"
    end if


    return "<" + valueType + ">"
end function





function rokucommunity_bslib_ternary(condition, consequent, alternate)
    if condition then
        return consequent
    else
        return alternate
    end if
end function




function rokucommunity_bslib_coalesce(consequent, alternate)
    if consequent <> invalid then
        return consequent
    else
        return alternate
    end if
end function