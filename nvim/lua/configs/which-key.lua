-- Inspired by surround-ui
--[[ 
  This version builds a flat list of mappings that conform to the new which‑key spec.
  The groups are:
    - <leader>S      → [surround]
    - <leader>Sa     → [around]
    - <leader>Si     → [inner]
    - <leader>Sc     → [change]
    - <leader>Sd     → [delete]
    - <leader>Ss     → [line]
--]]
-- Configurable root key for surround mappings (default "S")
local root_key = "S"

local grammar_targets = {
  ["["] = "",
  ["]"] = "",
  ["("] = "",
  [")"] = "",
  ["{"] = "",
  ["}"] = "",
  ["<"] = "",
  [">"] = "",
  ["`"] = "",
  ["'"] = "",
  ['"'] = "",
}

local abbreviated_targets = {
  ["b"] = " [bracket]",
}

local keywords_targets = {
  ["w"] = " [word]",
  ["W"] = " [WORD]",
  ["f"] = " [function]",
  ["q"] = " [quote]",
}

-- Merge tables
local all_targets = vim.tbl_extend("error", {}, grammar_targets, abbreviated_targets, keywords_targets)
local abbreviated_and_grammar_targets = vim.tbl_extend("error", {}, grammar_targets, abbreviated_targets)

local mappings = {}

-- Register the root group using the configurable root_key.
table.insert(mappings, { "<leader>" .. root_key, group = "[surround]" })

-- Around mappings: <leader>{root_key}a + <char><ichar>
table.insert(mappings, { "<leader>" .. root_key .. "a", group = "[around]" })
for char, _ in pairs(all_targets) do
  for ichar, target in pairs(abbreviated_and_grammar_targets) do
    local lhs = "<leader>" .. root_key .. "a" .. char .. ichar
    local rhs = '<CMD>call feedkeys("ysa\\' .. char .. "\\" .. ichar .. '")<CR>'
    local desc = "ysa" .. char .. ichar .. target
    table.insert(mappings, { lhs, rhs, desc = desc })
  end
end

-- Inner mappings: <leader>{root_key}i + <char><ichar>
table.insert(mappings, { "<leader>" .. root_key .. "i", group = "[inner]" })
for char, _ in pairs(all_targets) do
  for ichar, target in pairs(all_targets) do
    local lhs = "<leader>" .. root_key .. "i" .. char .. ichar
    local rhs = '<CMD>call feedkeys("ysi\\' .. char .. "\\" .. ichar .. '")<CR>'
    local desc = "ysi" .. char .. ichar .. target
    table.insert(mappings, { lhs, rhs, desc = desc })
  end
end

-- Change mappings: <leader>{root_key}c + <char><ichar>
table.insert(mappings, { "<leader>" .. root_key .. "c", group = "[change]" })
for char, _ in pairs(all_targets) do
  for ichar, target in pairs(all_targets) do
    local lhs = "<leader>" .. root_key .. "c" .. char .. ichar
    local rhs = '<CMD>call feedkeys("cs\\' .. char .. "\\" .. ichar .. '")<CR>'
    local desc = "cs" .. char .. ichar .. target
    table.insert(mappings, { lhs, rhs, desc = desc })
  end
end

-- Delete mappings: <leader>{root_key}d + <char>
table.insert(mappings, { "<leader>" .. root_key .. "d", group = "[delete]" })
for char, target in pairs(all_targets) do
  local lhs = "<leader>" .. root_key .. "d" .. char
  local rhs = '<CMD>call feedkeys("ds\\' .. char .. '")<CR>'
  local desc = "ds" .. char .. target
  table.insert(mappings, { lhs, rhs, desc = desc })
end

-- Line mappings: <leader>{root_key}s + <char>
table.insert(mappings, { "<leader>" .. root_key .. "s", group = "[line]" })
for char, target in pairs(all_targets) do
  local lhs = "<leader>" .. root_key .. "s" .. char
  local rhs = '<CMD>call feedkeys("yss\\' .. char .. '")<CR>'
  local desc = "yss" .. char .. target
  table.insert(mappings, { lhs, rhs, desc = desc })
end

require("which-key").add(mappings)
