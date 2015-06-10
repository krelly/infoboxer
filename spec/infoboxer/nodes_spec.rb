# encoding: utf-8
module Infoboxer
  describe Nodes do
    describe :inspect do
      subject{nodes.inspect}
      
      context 'by default' do
        let(:nodes){Nodes[Text.new('some text')]}
        
        it{should == '[#<Text: "some text">]'}
      end

      context 'really long children list' do
        let(:children){20.times.map{Text.new('some text')}}
        let(:nodes){Nodes[*children]}
        
        it{should == '[#<Text: "some text">, #<Text: "some text">, #<Text: "some text"> ...17 more]'}
      end

      context 'nested inside other' do
        let(:children){20.times.map{Text.new('some text')}}
        let(:nodes){Nodes[*children]}
        subject{nodes.inspect(2)}
        
        it{should == '[20 items]'}
      end
    end

    describe 'as Enumerable' do
      let(:nodes){Nodes[Text.new('one'), Text.new('two')]}

      it 'should be nodes always' do
        expect(nodes.select{|n| n.text == 'one'}).to be_a(Nodes)
        expect(nodes.reject{|n| n.text == 'one'}).to be_a(Nodes)
        expect(nodes.sort_by(&:text)).to be_a(Nodes)
      end
    end

    describe :<< do
      describe 'merging' do
        context 'text' do
          context 'when previous was text' do
            subject{Nodes[Text.new('test')]}
            before{
              subject << Text.new(' me')
            }
            it{should == [Text.new('test me')]}
          end

          context 'when previous was not a text' do
            subject{Nodes[Italic.new(Text.new('test'))]}
            before{
              subject << Text.new(' me')
            }
            it{should == [Italic.new(Text.new('test')), Text.new(' me')]}
          end

          context 'when its first text' do
            subject{Nodes[]}
            before{
              subject << 'test'
            }
            it{should == [Text.new('test')]}
          end
        end

        context 'paragraphs' do
          context 'when can merge' do
            subject{Nodes[Paragraph.new(Text.new('test'))]}
            before{
              subject << Paragraph.new(Text.new('me'))
            }
            it{should == [Paragraph.new(Text.new('test me'))]}
          end

          context 'when can\'t merge' do
            subject{Nodes[Paragraph.new(Text.new('test'))]}
            before{
              subject << Pre.new(Text.new('me'))
            }
            it{should == [Paragraph.new(Text.new('test')), Pre.new(Text.new('me'))]}
          end
        end
      end

      describe 'empty paragraphs dropping' do
        context 'into paragraph' do
          subject{Nodes[Paragraph.new(Text.new('test'))]}
          before{
            subject << EmptyParagraph.new(' ')
          }
          it{should == [Paragraph.new(Text.new('test'))]}
          its(:last){should be_closed}
        end

        context 'into pre' do
          subject{Nodes[Pre.new(Text.new('test'))]}
          before{
            subject << EmptyParagraph.new('   ')
          }
          it{should == [Pre.new(Text.new("test\n  "))]}
          its(:last){should_not be_closed}
        end

        context 'into pre -- really empty' do
          subject{Nodes[Pre.new(Text.new('test'))]}
          before{
            subject << EmptyParagraph.new('')
          }
          it{should == [Pre.new(Text.new("test"))]}
          its(:last){should be_closed}
        end
      end

      describe 'implicit flatten' do
        subject{Nodes[Text.new('test')]}
        before{
          subject << [Text.new(' me')]
        }
        it{should == [Text.new('test me')]}
      end

      describe 'ignoring of empty nodes' do
        context 'text' do
          subject{Nodes[Italic.new(Text.new('test'))]}
          before{
            subject << Text.new('')
          }
          it{should == [Italic.new(Text.new('test'))]}
        end

        context 'compound' do
          subject{Nodes[Paragraph.new(Text.new('test'))]}
          before{
            subject << Pre.new()
          }
          it{should == [Paragraph.new(Text.new('test'))]}
        end

        context 'but not HTML!' do
          subject{Nodes[Paragraph.new(Text.new('test'))]}
          before{
            subject << HTMLTag.new('br', {})
          }
          it{should == [Paragraph.new(Text.new('test')), HTMLTag.new('br', {})]}
        end

        context 'empty paragraphs' do
          subject{Nodes[Heading.new(Text.new('test'), 2)]}
          before{
            subject << EmptyParagraph.new(' ')
          }
          it{should == [Heading.new(Text.new('test'), 2)]}
        end
      end
    end
  end
end
