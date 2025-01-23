// Demonstration of basic, raw access to ImGui with the DEFER
// macro for ensuring begins are matched with ends.
//
// See "dear_example" for using more modern C++ that doesn't
// involve macros.

//#include "imguiwrap.helpers.h"
#include "imgui.h"
#include "imguiwrap.h"
#include "imguiwrap.defermacro.h"

//#include <string_view>

namespace{
ImGuiWrapperReturnType
windowFn()
{
    static bool show_visualizer{true};
    DEFER(ImGui::End(););
    // If the user closes the visualizer, exit with rc 0.
    if (!ImGui::Begin("Visualizer", &show_visualizer)) {
        return 0;
	}

    ImGui::Text("hello");
    if (ImGui::BeginTabBar("##TabBar")) {
        DEFER(ImGui::EndTabBar(););
        if (ImGui::BeginTabItem("Files")) {
            DEFER(ImGui::EndTabItem(););
            ImGui::Text("...files...");
        }
        if (ImGui::BeginTabItem("Blueprints")) {
            DEFER(ImGui::EndTabItem(););
            ImGui::Text("...blueprints...");
        }
        if (ImGui::BeginTabItem("Enums")) {
            DEFER(ImGui::EndTabItem(););
            ImGui::Text("... enums...");
        }
        if (ImGui::BeginTabItem("Prototypes")) {
            DEFER(ImGui::EndTabItem(););
            ImGui::Text("... prototypes...");
        }
    }

    // Return nothing.
    return {};
}
}

int
main(int, const char**)
{

    constexpr ImGuiWrapConfig config{.windowTitle_ = "Basic Example", .width_ = 1280, .height_ = 600};
    return imgui_main(config, windowFn);
}
