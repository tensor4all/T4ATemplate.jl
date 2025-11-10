using T4ATemplate

function main()
    return T4ATemplate.generate()
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

