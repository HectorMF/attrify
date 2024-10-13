# frozen_string_literal: true

RSpec.describe Attrify::Parser do
  describe ".parse_base" do
    context "when no slot is defined" do
      it "wraps the code in the main slot" do
        expect(Attrify::Parser.parse_base(
          {
            id: 10,
            class: %w[inline-flex items-center justify-center],
            style: "color: red;",
            data: {
              controller: "stimulus_controller"
            }
          }
        )).to eq(
          main:
          {
            attributes: {
              id: [{set: ["10"]}],
              class: [{set: %w[inline-flex items-center justify-center]}],
              style: [{set: ["color: red;"]}],
              data: {
                controller: [{set: ["stimulus_controller"]}]
              }
            }
          }
        )
      end
    end

    context "when the main slot is already defined" do
      it "parses the operations and doesn't change the structure" do
        expect(Attrify::Parser.parse_base(
          {
            main: {
              id: 10,
              class: %w[inline-flex items-center justify-center],
              style: "color: red;",
              data: {
                controller: "stimulus_controller"
              }
            }
          }
        )).to eq(
          main:
          {
            attributes: {
              id: [{set: ["10"]}],
              class: [{set: %w[inline-flex items-center justify-center]}],
              style: [{set: ["color: red;"]}],
              data: {
                controller: [{set: ["stimulus_controller"]}]
              }
            }
          }
        )
      end
    end

    context "when the a slot that isn't main is already defined" do
      it "parses the operations and doesn't change the structure" do
        expect(Attrify::Parser.parse_base(
          {
            button: {
              id: 10,
              class: %w[inline-flex items-center justify-center],
              style: "color: red;",
              data: {
                controller: "stimulus_controller"
              }
            }
          }
        )).to eq(
          button:
          {
            attributes: {
              id: [{set: ["10"]}],
              class: [{set: %w[inline-flex items-center justify-center]}],
              style: [{set: ["color: red;"]}],
              data: {
                controller: [{set: ["stimulus_controller"]}]
              }
            }
          }
        )
      end
    end

    context "when multiple slots are defined" do
      it "correctly handles the parsing of the slot structures" do
        expect(Attrify::Parser.parse_base(
          {
            avatar: {
              class: %w[inline-flex items-center justify-center]
            },
            accept_button: {
              color: :primary,
              size: :sm
            }
          }
        )).to eq({
          avatar: {
            attributes: {
              class: [{set: %w[inline-flex items-center justify-center]}]
            }
          },
          accept_button: {
            attributes: {
              color: [{set: ["primary"]}],
              size: [{set: ["sm"]}]
            }
          }
        })
      end
    end
  end
end
